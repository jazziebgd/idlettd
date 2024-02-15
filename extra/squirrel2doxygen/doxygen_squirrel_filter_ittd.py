#!/usr/bin/env python
# -*- coding: utf-8 -*-	
#
# This is a filter to convert IdleTTD Squirrel (*.nut) scripts
# into something doxygen can understand.
#
# Extends class from the original squirrel2doxygen library (C) 2015, 2019  Jacob Boerema
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


keep_function = True;
keep_constructor = True;
check_end_of_class = True;
track_class_functions = True;
hide_private_symbols = True;

# --------------------------------------------------------------

if track_class_functions:
	check_end_of_class = True;

import sys
import re
from doxygen_squirrel_filter import ClassData, SquirrelFilter;

def debug(string):
	sys.stderr.write(string);

class SquirelFilterIdleTTD(SquirrelFilter):
	# deoends on keep_constructor / keep_function being true
	re_function_with_params_2 = re.compile("\s*(?:function|constructor)[^(]*\(([^)]+)\)");

	re_configvar_struct = re.compile("^(::)(ScriptConfig.+)$");

	re_min_version_to_load = re.compile("^(ScriptMinVersionToLoad)");
	re_last_update_date = re.compile("^(ScriptLastUpdateDate)");
	re_seconds_per_day = re.compile("^(SecondsPerGameDay)");
	re_ticks_per_day = re.compile("^(TicksPerGameDay)");

	# "dumb" processing of particular function arguments
	def process_function_param_types(self, part):
		output = part;
		temp = self.re_function_with_params_2.search(output);	
		
		if temp:
			grps = temp.groups();
			paramgroup = temp.group(len(grps));
			pgstart = temp.start(len(grps));
			last = grps[len(grps) - 1];
			
			newparams = [];
			
			for mo in re.finditer(r"([^,]+)", last):
				start = pgstart + mo.start();
				end = start + mo.end();
				val = str(mo.group(1)).strip();
				newVal = val;
				if re.match(r'^companyID', newVal):
					newVal = "int " + newVal;
				elif re.match(r'^storyPageID', newVal):
					newVal = "int " + newVal;
				elif re.match(r'^element', newVal):
					newVal = "GSText " + newVal;
				elif re.match(r'^(pageDate|date)', newVal):
					newVal = "GSDate " + newVal;
				elif re.match(r'^event', newVal):
					newVal = "GSEventStoryPageButtonClick " + newVal;
				elif re.match(r'^vehicleSummary', newVal):
					newVal = "StructSummaryVehicleStats " + newVal;
				elif re.match(r'^buttonReference', newVal):
					newVal = "StoryPageButtonFormatting " + newVal;
				elif re.match(r'^allVehicleStats', newVal):
					newVal = "array< StructVehicleTypeStatsItem, 4> " + newVal;
				elif re.match(r'^vehicleType', newVal):
					newVal = "int " + newVal;
				elif re.match(r'^tbl', newVal):
					newVal = "StructScriptSavedData " + newVal;
				elif re.match(r'^tableToLog', newVal):
					newVal = "SQTable " + newVal;
				elif re.match(r'^(balanceChange|lastYearBalance|secondToLastYearBalance|idleBalance|totalAmount)', newVal):
					newVal = "int " + newVal;
				elif re.match(r'^(logLevel|version|fromVersion|toVersion|buttonId|lastActiveTime|forceTimeUnit|inactiveSeconds|totalSeconds|ratio)', newVal):
					newVal = "int " + newVal;
				elif re.match(r'^(memberKey|memberValue|customText|message|tableIdentifier|prependText)', newVal):
					newVal = "string " + newVal;


				# try to determine type by devault value (for params that have them)
				elif re.match(r'^bool[a-zA-Z_[0-9]+$', newVal):
					newVal = "bool " + newVal;
				elif re.match(r'^int[a-zA-Z_[0-9]+$', newVal):
					newVal = "int " + newVal;
				elif re.match(r'^float[a-zA-Z_[0-9]+$', newVal):
					newVal = "float " + newVal;
				elif re.match(r'^string[a-zA-Z_[0-9]+$', newVal):
					newVal = "string " + newVal;
				elif re.match(r'.*=\s*(true|false)$', newVal):
					newVal = "bool " + newVal;
				elif re.match(r'.*=\s*\d*$', newVal):
					newVal = "int " + newVal;
				elif re.match(r'.*=\s*"[^"]+"$', newVal):
					newVal = "string " + newVal;
				
				
				

				newparams.append(newVal);
				
			newParamCount = len(newparams);
			fparams = "";
			if newParamCount > 0:
				
				for paramindex in range(newParamCount) :
					fparams += newparams[paramindex];
					if paramindex < newParamCount - 1:
						fparams += ", ";
			
				newfunc = output[:temp.start(1)] + fparams +  output[temp.end(1):];
				
				output = newfunc;
		return output;
		
	# processing of config.nut file 
	def process_config_file(self, part):
		output = part;
		temp = self.re_configvar_struct.search(output);
		if temp:
			output = " StructGameScriptConfig " + temp.group(2);
		return output;
	
	# processing of constants.nut file 
	def process_constants_file(self, part):
		output = part;
		temp = self.re_min_version_to_load.search(output);
		if temp:
			output = output[:temp.start(1)] + "int " + temp.group(1) +  output[temp.end(1):];
	
	
		temp = self.re_last_update_date.search(output);
		if temp:
			output = output[:temp.start(1)] + "string " + temp.group(1) +  output[temp.end(1):];

		temp = self.re_seconds_per_day.search(output);
		if temp:
			output = output[:temp.start(1)] + "float " + temp.group(1) +  output[temp.end(1):];
		
		temp = self.re_ticks_per_day.search(output);
		if temp:
			output = output[:temp.start(1)] + "int " + temp.group(1) +  output[temp.end(1):];
		return output;

	# Override that adds idlettd specific processing at the end. Basically a copy of superclass one with added idlettd transformations before adding result to output buffer.
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
			# alwaysprint("class " + self.current_class + "\n");
		
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

		output = self.process_function_param_types(output);
				
		if re.search(r'constants\.nut$', self.filename):
			output = self.process_constants_file(output);
			
		if re.search(r'config\.nut$', self.filename):
			output = self.process_config_file(output);
	
		# Add output to buffer.
		self.outbuf += output;










# --------------------------------------------------------------------------------------------------
## This is our main function. We check for correct arguments here and then start our filter.
# --------------------------------------------------------------------------------------------------

if len(sys.argv) != 2:
	debug("usage: " + sys.argv[0] + " filename");
	sys.exit(1);


# Filter the specified file and print the result to stdout
filename = sys.argv[1] ;

debug("Filtering IdleTTD file " + filename + ".\n")

DoxygenFilter = SquirelFilterIdleTTD(filename);
DoxygenFilter.filter();

sys.exit(0);
