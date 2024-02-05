#!/usr/bin/env python
# -*- coding: utf-8 -*-	
#
# This is a filter to convert Squirrel (*.nut) scripts
# into something doxygen can understand.
# Copyright (C) 2015, 2019  Jacob Boerema
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
# ------------------------------------------------------------------------- 

## @file doxygen_squirrel_filter.py Filter for Squirrel to make doxygen understand it as C++.

## @author Jacob Boerema
## @date 2015, 2019
## @version 2.0
## @copyright GPL version 2
## Repositories:
## http://dev.openttdcoop.org/projects/squirrel2doxygen/repository
## https://bitbucket.org/jacobb/squirrel2doxygen

## Instructions.
## -------------
## Set the following items in your doxygen config file
## 1. EXTENSION_MAPPING: Add: nut=C++
## 2. FILE_PATTERNS: Add: *.nut
## 3. FILTER_PATTERS: Add:
## + *.nut=doxygen_squirrel_filter.bat [or]
## + *.nut=doxygen_squirrel_filter.py
## For the first option you need to adapt the path to python in the batch file.
## In case of the second option make sure that python is on your path and that
## python is set for files with extension .py and possibly you also need to
## set the path to the python script.

## Known problems:
## ---------------
## 1. Inline code in the file outside of any function can confuse doxygen too sometimes
## Example: AILib.List main.nut the code at the bottom.
## 2. Multi line string constants not supported: (starting with @" ). Note multi line string
## constants also support " inside them by writing ""
## 3. Doxygen can get confused by class names that have a "." in them.
## 4. Doxygen gets confused if global const or enum declarations don't get ended by a
## semicolon ";". If your documentation gets cut short then looking for missing semicolons
## is the first thing to check.


# First version: 2015-06-15/17
# Tested on Windows 7 with Squirrel version 2.2 as used by OpenTTD for AI and game scripts.
# Version 2: 2015-06-21
# Updated October 2019 to also work with python 3.

# --------------------------------------------------------------
# Settings that can be changed by the user of our doxygen filter
# --------------------------------------------------------------

## Do we want to keep function or replace it with ""
keep_function = True;

## Do we want to keep constructor or replace it with ""
keep_constructor = True;

## Check for "}" at end of class definition and add a ";"if it's not there.
## You can speed up filtering by turning this off if you always add a ";" yourself
## @note if track_class_functions is True then this variable will always be set to True.
## Now also used for any closing brace "}" without ";".
check_end_of_class = True;

## Track all member functions of all classes and add them inside the class if necessary.
## Will slow down parsing but is necessary if not all member functions are inside the class definition.
track_class_functions = True;

## Do we want to hide private functions, variables etc or not.
## A symbol is considered private if it starts with an underscore.
## @note Classes themselves are currently never considered private otherwise we would not
## be able to document the SuperLib classes.
## @note Currently only marking private inside classes is supported.
hide_private_symbols = True;

# --------------------------------------------------------------

## If track_class_functions is True the check_end_of_class needs to be True too.
if track_class_functions:
	check_end_of_class = True;

# Import some libraries that we need.
import os
import io
import sys
import re


## Turn debugging info printing on or off
print_debug_info = False;

# constants
MAX_POS_ON_LINE = 999999;


## Print a string to stderr
def alwaysprint(string):
	sys.stderr.write(string);

## ClassData is our class to keep track of the functions used in a class.
class ClassData:
	def __init__(self, name):
		self.classname = name;
		self.functions = [];
		self.missing = [];
		self.params = [];
		self.output_buffer = "";
	
	def AddClassMemberFunctionInside(self, name):
		self.functions.append(name);

	def AddClassMemberFunctionOutside(self, name):
		self.missing.append(name);

	def AddMemberFunctionParams(self, parameters):
		self.params.append(parameters);
	
	def SetBuffer(self, outbuf):
		self.output_buffer = outbuf;


## SquirrelFilter is our class to convert Squirrel scripts to something doxygen can understand.
class SquirrelFilter:

	# ----------------------------------
	# Class Variables.
	# ----------------------------------

	## doxygen reads data from stdout so that's where we are going to send our filtered output.
	outfile = sys.stdout;

	## Keep track of being in a multi line comment or not
	in_multiline_comment = False;

	## Keep track of the last seen class name
	current_class = "";

	## Determines if we are looking for a class definition block: "{"
	want_class_start = False;
	
	## Determines if we are looking for end of class "}"
	want_class_end = False;

	## Determines at what level we are in the code blocks hierarchy needed to find end of class.
	block_level = 0;
	
	## Classes found in the currently processed file.
	classes = [];
	class_names = [];
	
	## We need an output buffer since we can only determine for sure after we have read the whole
	## file whether we need to make come changes to certain classes.
	## This buffer will contain the part of the output since the beginning of the file or since
	## we encountered an end of class marker.
	outbuf = "";

	# ----------------------------------

	# regular expressions

	# 1. Comments and string constants
	re_multiline_comment_start = re.compile("\/[*]");
	re_multiline_comment_end = re.compile("[*]\/");
	re_singleline_comment = re.compile("\/\/");

	## The following regular expression confuses doxygen's inbuilt python parser.
	## Any code documentation starting with this and anything below it will be ignored.
	## re_string = re.compile('"');
	## Work around doxygen problem described above
	double_quote = '"';
	re_string = re.compile(double_quote);

	# 2. Squirrel language constructs that need changing
	re_assignment = re.compile("<-");
	re_extends = re.compile("extends");
	re_require = re.compile("require\s*\(");
	re_import = re.compile("import\s*\(");

	# Maybe keep function and constructor. Even though doxygen will think its the function result
	# it might look nice in the documentation to see those Squirrel names.
	# Or make it a variable that can be set whether to remove it or not.
	re_constructor = re.compile("constructor");
	re_function = re.compile("function");

	## @todo Support functions starting with _ as being private.
	## Support comments /* public: */ and /* private: */ and change it to keywords public: and private:

	# 3. Squirrel elements we need to find
	re_blockstart = re.compile("\{");
	re_blockend = re.compile("\}");
	re_functionend = re.compile("\)");
	re_classend = re.compile("\s*;");
	re_classname = re.compile("\s*class\s+([a-zA-Z_]+[a-zA-Z_0-9.]*)");
	re_functionname = re.compile("\s*(function)\s+([a-zA-Z_]+[a-zA-Z_0-9]*)");
	# WARNING: Params can be spread over multiple lines so we can't use it in regexp!
	#re_classfunctionname = re.compile("\s*function\s+([a-zA-Z_]+[a-zA-Z_0-9]*)::([a-zA-Z_]+[a-zA-Z_0-9]*)(\s*\([^)]*)");
	re_classfunctionname = re.compile("\s*(function)\s+([a-zA-Z_]+[a-zA-Z_0-9.]*)::([a-zA-Z_]+[a-zA-Z_0-9]*)");
	# Can't use the following re because it also matches abc_def = ...
	# And since a variable can start at the beginning of a line we can't use \s+
	#re_privatevar = re.compile("\s*(_[a-zA-Z_0-9]*)\s+=");
	re_privatevar = re.compile("\s*([a-zA-Z_0-9]*)\s+=");
	re_privateenum = re.compile("\s*(enum)\s+(_[a-zA-Z_0-9]*)");

	def __init__(self, filename):
		self.filename = filename;
		self.outbuf = "";
		## Tells if we are looking for a functions parameters
		self.need_function_params = False;
		## The buffer to store the function parameters in
		self.params_buf = "";
		self.cur_class = None;

	## Print a string to stderr if print_debug_info is True
	def debugprint(self, string):
		#global print_debug_info
		if (print_debug_info):
			sys.stderr.write(string);

	## Determine if the first match is a multi line comment, single line comment or string start
	def first_match(self, ml_comment, sl_comment, str_start):
		if (ml_comment is None and sl_comment is None and str_start is None):
			self.debugprint("....... All None");
			return None;
		if (ml_comment is None):
			self.debugprint("....... No multi line");
			pos_ml = MAX_POS_ON_LINE;
		else:
			pos_ml = ml_comment.start();
			if (pos_ml is None):
				pos_ml = MAX_POS_ON_LINE;
		if (sl_comment is None):
			self.debugprint("....... No single line");
			pos_sl = MAX_POS_ON_LINE;
		else:
			pos_sl = sl_comment.start();
			if (pos_sl is None):
				pos_sl = MAX_POS_ON_LINE;
		if (str_start is None):
			self.debugprint("....... No string");
			pos_str = MAX_POS_ON_LINE;
		else:
			pos_str = str_start.start();
			if (pos_str is None):
				pos_str = MAX_POS_ON_LINE;
		if (pos_ml < pos_sl and pos_ml < pos_str):
			return ml_comment;
		elif (pos_sl < pos_ml and pos_sl < pos_str):
			return sl_comment;
		else:
			return str_start;

	## Checks if a ";" follows end of block "}" and checks if this is the end of a class.
	def check_end_of_class(self, part):
		# Check if a ";" follows, if not add it or doxygen can get somewhat confused.
		block_end = self.re_classend.match(part);
		if (block_end is None):
			# No ";" so add it.
			part = ";" + part;
		# Assuming for now that we don't encounter nested classes!
		if (self.want_class_end == True and self.block_level == 0):
			self.want_class_end = False;
			self.cur_class = None;
			self.debugprint("<end of class>\n");

		return part;
	
	## old_output is the already filtered part of the line; last_part is the part before "}"
	def end_of_block(self, old_output, last_part):
		self.block_level -= 1;
		self.debugprint("*** " + str(self.block_level) + " ***");
		old_output += last_part;
		# For now we hardcode end of class level at level 0
		if (self.block_level == 0 and self.want_class_end == True):
			# End of Class. Add buffer to Class and set current buffer back to ""
			self.outbuf += old_output;
			self.cur_class.SetBuffer(self.outbuf);
			# Rest buffer
			self.outbuf = "";
			# Add the closing "}" of the class back to output
			old_output = "}";
		else:
			old_output += "}";
		return old_output;
	
	## Parse "{" and "}" to keep track of the code level.
	def parse_blocks(self, part):
		output = "";
		while (True):
			blockstart = self.re_blockstart.search(part);
			blockend = self.re_blockend.search(part);
			if blockstart and blockend:
				# both available, determine which comes first
				if (blockstart.start() < blockend.start()):
					# block start comes first: increase level
					self.block_level += 1;
					self.debugprint("*** " + str(self.block_level) + " ***");
					output += part[:blockstart.end()];
					part = part[blockstart.end():];
				else:
					# block end comes first: decrease level
					output = self.end_of_block(output, part[:blockend.start()]);
					part = self.check_end_of_class(part[blockend.end():]);
			elif blockstart:
				# Only start of block available: increase block level
				self.block_level += 1;
				self.debugprint("*** " + str(self.block_level) + " ***");
				output += part[:blockstart.end()];
				part = part[blockstart.end():];
			elif blockend:
				# Only end of block available: decrease block level
				output = self.end_of_block(output, part[:blockend.start()]);
				part = self.check_end_of_class(part[blockend.end():]);
			else:
				output += part;
				break;
			
			# Make sure we don't get into an endless loop
			if (self.block_level < 0 or self.block_level > 50):
				raise ValueError("Endless loop detected in parse_blocks! Block level is " + str(self.block_level));

		return output;

	## Checks whether we have reached the end of a function's parameters.
	def check_params_end(self, part):
		if self.need_function_params:
			temp = self.re_functionend.search(part);
			if temp:
				# Found end of params
				self.params_buf += part[:temp.end()];
				self.cur_class.AddMemberFunctionParams(self.params_buf);
				self.need_function_params = False;
				self.params_buf = "";
			else:
				self.params_buf += part;

	## Filter the string part
	## @note We currently only allow one of each element on a line.
	def filter_part(self, part):
		output = part;
		start_pos = 0;
		
		# Replace <- with =
		assignment = self.re_assignment.search(output);
		if (assignment is not None):
			output = output[:assignment.start()] + "=" + output[assignment.end():]
		else:
			output = part;

		# Replace extends with :
		extends = self.re_extends.search(output);
		if (extends is not None):
			output = output[:extends.start()] + ":" + output[extends.end():]

		# Get class name if a class is defined
		classname = self.re_classname.search(output);
		if classname:
			self.want_class_start = True;
			start_pos = classname.end();
			self.current_class = classname.group(1);
			self.cur_class = ClassData(self.current_class);
			self.classes.append(self.cur_class);
			self.class_names.append(self.current_class);
			alwaysprint("class " + self.current_class + "\n");
		
		# Check if we can find a class start block
		if self.want_class_start:
			first_part = output[:start_pos];
			last_part = output[start_pos:];
			class_start = self.re_blockstart.search(last_part);
			if class_start:
				self.want_class_start = False;
				self.want_class_end = True;
				output = first_part + last_part[:class_start.end()] + "public:" + last_part[class_start.end():];

		# Check for a function and register it's name if tracking is on
		if track_class_functions:
			if self.need_function_params:
				self.check_params_end(output);
			if self.want_class_end:
				# Inside a class we only need to register functions names
				fn_name = self.re_functionname.search(output);
				if fn_name:
					self.cur_class.AddClassMemberFunctionInside(fn_name.group(2));
					# Check if function name starts with a "_" (private function)
					if hide_private_symbols and fn_name.group(2).startswith("_"):
						output = output[:fn_name.start(1)] + " /** @private */ " + output[fn_name.start(1):];
			elif (self.block_level == 0):
				#Outside a class. Assuming we can only start class functions at the outermost level
				fn_name = self.re_classfunctionname.search(output);
				if fn_name:
					cname = fn_name.group(2);
					fname = fn_name.group(3);
					cidx = self.class_names.index(cname);
					# Set current class to the class of this function.
					self.cur_class = self.classes[cidx];
					if (self.classes[cidx].functions.count(fname) == 0 and
						not (hide_private_symbols and fn_name.group(3).startswith("_"))):
						# Not found in list of classes, add to missing
						self.cur_class.AddClassMemberFunctionOutside(fname);
						# Looking for functions params now
						self.need_function_params = True;
						self.check_params_end(output[fn_name.end(3):]);

		# Hide private variables/enums if needed
		# Only at global scope (level 0) or global class scope (level 1)
		if (hide_private_symbols and (self.block_level == 0 or
			(self.want_class_end and self.block_level == 1))):
			temp = self.re_privatevar.search(output);
			if temp:
				# Make sure it starts with _
				if temp.group(1).startswith("_"):
					# private variable: add private: marker
					if self.block_level == 0:
						## @bug This does not work. Maybe comment the whole source line?
						## But then what if a variable ends on a different line.
						doxy_cmd = " /** @internal */ ";
					else:
						doxy_cmd = " /** @private */ ";
					output = output[:temp.start(1)] + doxy_cmd + output[temp.start(1):];
			# Test for private enumerate
			temp = self.re_privateenum.search(output);
			if temp and temp.group(2).startswith("_"):
				if self.block_level == 0:
					## @bug This does not work. Maybe comment the whole source line?
					## But then what if an enum ends on a different line, which is likely.
					doxy_cmd = " /** @internal */ ";
				else:
					doxy_cmd = " /** @private */ ";
				output = output[:temp.start(1)] + doxy_cmd + output[temp.start(1):];

		# Replace constructor with the class name
		constr = self.re_constructor.search(output);
		if constr:
			if (keep_constructor == False):
				output = output[:constr.start()] + self.current_class + output[constr.end():];
			else:
				output = output[:constr.end()] + " " + self.current_class + output[constr.end():];
				
		if (keep_function == False):
			# Replace function with nothing
			temp = self.re_function.search(output);
			if temp:
				output = output[:temp.start()] + output[temp.end():];

		temp = self.re_require.search(output);
		if temp:
			# Found require, replace by #include. We don't bother with the closing ")" since it seems doxygen doesn't care.
			output = output[:temp.start()] + "#include " + output[temp.end():];
		temp = self.re_import.search(output);
		if temp:
			# Found import, replace by #include. We don't bother with the closing ")" since it seems doxygen doesn't care.
			output = output[:temp.start()] + "#include " + output[temp.end():];

		# Check for reaching end of class brace.
		# Also makes sure any "}" is always followed by a ";".
		if check_end_of_class:
			output = self.parse_blocks(output);

		# Add output to buffer.
		self.outbuf += output;

	## Handle one line of text and send to buffer after filtering.
	def line_handler(self, line, lineno):
		start_pos = 0;
		temp_line = line[start_pos:]

		while(True):
			if (self.in_multiline_comment):
				ml_end = self.re_multiline_comment_end.search(temp_line);
				if (ml_end is None):
					# End of multi line comment not found on this line
					self.outbuf += temp_line;
					break;
				else:
					# End of multi line comment found
					self.in_multiline_comment = False;
					self.outbuf += temp_line[:ml_end.end()];
					temp_line = temp_line[ml_end.end():];
			else:
				ml_start = self.re_multiline_comment_start.search(temp_line);
				sl_start = self.re_singleline_comment.search(temp_line);
				str_start = self.re_string.search(temp_line);
				next_match = self.first_match(ml_start, sl_start, str_start);
				if next_match is None:
					self.filter_part(temp_line);
					break;
				elif next_match == ml_start:
					self.in_multiline_comment = True;
					# Filter part before the multi line comment starts and add to output
					self.filter_part(temp_line[:ml_start.end()]);
					temp_line = temp_line[ml_start.end():];
				elif next_match == sl_start:
					# First filter the part before the comment starts, then add the comment itself unfiltered
					self.filter_part(temp_line[:sl_start.start()]);
					self.outbuf += temp_line[sl_start.start():];
					break;
				else:
					# Filter the part before the string starts and add to output
					self.filter_part(temp_line[:str_start.start()]);
					# Then try to find the end of string
					temp_line = temp_line[str_start.start():]
					str_end = self.re_string.search(temp_line);
					if (str_end is None):
						#Error
						alwaysprint("** Warning: didn't find end of string on line" + str(lineno+1));
						# Add the string contents to output
						self.outbuf += temp_line;
						break;
					else:
						# Add the string contents to output
						self.outbuf += temp_line[:str_end.end()];
						temp_line = temp_line[str_end.end():]

	## Write the data in buffer to outfile (stdout)
	def WriteBuf(self, buffer):
		try:
			# Encode output because otherwise in e.g. TownManager.nut you get an encoding error (degree symbol)
			# To make it work in both python 2 and 3 we check the version here
			if sys.version_info[0] < 3:
				self.outfile.write(buffer.encode("utf-8"));
			else:
				self.outfile.buffer.write(buffer.encode("utf-8"));
		except UnicodeEncodeError as e:
			alwaysprint("*** Unicode encoding error!\n");
	
	## Filter the file and output to stdout
	def filter(self):
		self.outfile = sys.stdout;

		# Open file for reading
		nut_file = io.open(self.filename, "r", newline='', encoding='utf-8')   # newline='' means don't convert line endings
		lines = nut_file.readlines();
		nut_file.seek(0);

		# Parse all lines in file
		for i, line in enumerate(lines):
			self.line_handler(line, i);

		if keep_function:
			function_str = "function ";
		else:
			function_str = "";
		# Write buffered data per class and add missing functions if needed.
		for classdata in self.classes:
			# Write buffer of everything before end of class block to output
			self.WriteBuf(classdata.output_buffer);
			
			#alwaysprint("Class " + classdata.classname + "\n");
			#alwaysprint("----- functions defined inside class -----\n");
			#for idx, fn in enumerate(classdata.functions):
			#	alwaysprint("function " + fn + "\n");
			if len(classdata.missing) > 0:
				alwaysprint("----- missing functions inside class " + classdata.classname + "-----\n");
				for idx, fn in enumerate(classdata.missing):
					alwaysprint("function " + fn + "\n");
					self.WriteBuf(function_str + fn + classdata.params[idx] + ";\n");

		# Write buffer of everything after the last class definition block.
		self.WriteBuf(self.outbuf);

		# Close our file
		nut_file.close();

# --------------------------------------------------------------------------------------------------
## This is our main function. We check for correct arguments here and then start our filter.
# --------------------------------------------------------------------------------------------------
alwaysprint("Starting doxygen Squirrel filter.\n")

if len(sys.argv) != 2:
	alwaysprint("usage: " + sys.argv[0] + " filename");
	sys.exit(1);


# Filter the specified file and print the result to stdout
filename = sys.argv[1] ;

alwaysprint("Filtering file " + filename + ".\n")

DoxygenFilter = SquirrelFilter(filename);
DoxygenFilter.filter();

sys.exit(0);
