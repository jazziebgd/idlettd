Doxygen filter for Squirrel
===========================

This is a doxygen filter to convert Squirrel scripts into something
resembling C++ code that doxygen can parse for documentation comments.   
It has been tested on Windows 10 with python 2.7 and python 3.7 and is
also known to work on the Linux infrastructure of openttdcoop.org.    
It was designed for Squirrel version 2.2 as used by OpenTTD for
AI and Game scripts.

Usage instructions
------------------
Set the following items in your doxygen config file.

1. EXTENSION_MAPPING: Add: nut=C++    
2. FILE_PATTERNS: Add: *.nut    
3. FILTER_PATTERNS: Add either:    
    + \*.nut=doxygen\_squirrel\_filter.bat [or]    
    + \*.nut=doxygen\_squirrel\_filter.py    
For the first option you need to adapt the path to python in the batch
file.    
In case of the second option make sure that python is on your path and
that python is set for files with extension .py and possibly you also need to
set the path to the python script.    
In both cases you may have to add a path to the batch or python file.

Known problems
--------------
1. Inline code in the file outside of any function can confuse doxygen
too sometimes.    
    Example: AILib.List main.nut the code at the bottom.
2. Multi line string constants are not supported: (starting with @" ).
3. Doxygen can get confused by class names that have a "." in them.
4. Doxygen gets confused if global const or enum declarations don't get
ended by a semicolon ";". If your documentation gets cut short then
looking for missing semicolons is the first thing to check.

Settings
--------
There are a few settings inside doxygen\_squirrel\_filter.py that
you can change to your personal preferences.

1. keep\_function = True or False    
Determines if you want to keep the keyword **function** or not.
2.  keep\_constructor = True or False    
Determines if you want to keep the keyword **constructor** or not.
3. check\_end\_of\_class = True or False    
Determines if you want to check if a ';' follows the closing '}'
of a class definition. You can speed up filtering by turning this
off if you always add a ";" yourself.    
4. track\_class\_functions = True or False    
Determines if you want to track all member functions of all classes and add them inside the class if necessary, since Squirrel allows class member functions to be declared outside the class itself.    
Note that this will slow down parsing considerably but is necessary if not all member functions are inside the class definition.
If this option is set to True then check\_end\_of\_class will also be set to True.
5. hide\_private\_symbols = True or False    
Determines if you want to hide private functions, variables and enums or not.    
A symbol is considered private if it starts with an underscore.    
Notes:
 + Classes themselves are currently never considered private otherwise we would not be able to document the SuperLib classes.    
 + Currently only marking private inside classes is supported.

Copyright
---------
Copyright Jacob Boerema 2015, 2019.    
License: GPL version 2.

Repository
----------
The source code can be downloaded from:
https://github.com/Wormnest/squirrel2doxygen


