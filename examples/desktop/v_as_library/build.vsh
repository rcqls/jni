// Copyright(C) 2019-2021 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package
//
// export JAVA_HOME="/path/to/jdk/root"
// export LD_LIBRARY_PATH="$(pwd)":$LD_LIBRARY_PATH
// v -prod -shared libvlang.v && javac io/vlang/V.java && java io.vlang.V
//
import os

fn java_home() string {
	mut java_home := os.getenv('JAVA_HOME')
	if java_home != '' {
		return java_home.trim_right(os.path_separator)
	}
	possible_symlink := os.find_abs_path_of_executable('javac') or { return '' }
	java_home = os.real_path(os.join_path(os.dir(possible_symlink), '..'))
	return java_home.trim_right(os.path_separator)
}

javahome := java_home()
javac := os.find_abs_path_of_executable('javac') or { '' }
java := os.find_abs_path_of_executable('java') or { '' }

if javahome == '' || javac == '' {
	eprintln('could not detect Java install. Please set JAVA_HOME')
	exit(1)
}

os.setenv('JAVA_HOME',javahome,false)
os.setenv('LD_LIBRARY_PATH',os.getenv('LD_LIBRARY_PATH')+os.path_delimiter+os.getwd(),true)

eprintln('Compiling shared libvlang.o')
os.system('v -prod -shared libvlang.v')
eprintln('Compiling Java sources')
os.system(javac+' io/vlang/V.java')
eprintln('Running Java application')
os.system(java+' io.vlang.V')
