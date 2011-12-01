" Author PJG <pjg864@163.com>

"-------------------------------------------------------------
" Hello! Here're some details about this script:
"
"   1) Usage: in your project directory, execute 
"
"           $ gvim -S /path/to/this_script.vim
"
"   2) Tips One: If you use GUI in linux, you can make a directory, 
"   such as ~/bin/, put this script file in it, then write a shell 
"   script like this:
"
"           #!/bin/bash
"           gvim -S ~/bin/project.vim
"
"      You can name it as "open_project". Then execute:
"           
"           $ chmod +x open_project
"
"      Put this shell script in the same directory as project.vim. 
"   Then add ~/bin/ to your PATH environment
"
"           $ export PATH=$PATH:~/bin
"
"           --or--
"           
"           $ echo 'export PATH=$PATH:~/bin' >> ~/.bashrc
"
"   	After you have done, you can 'cd ' to your project dir,
"   then execute 'open_project'.
"   	
"   	Well, the most FANTASTIC thing is that you can put the
"   shell script in your ~/.gnome2/nautilus-scripts/ directory,
"   then you can find your nautilus "right-mouse" menu turns out
"   a content, named "open_project". So, go to your C project 
"   directory, and "right-click" the empty place, select "open_project",
"   you will get what you want!
"
"   3) Tips Two: If you use Microsoft OS, you can write a bat file,
"   like this:
"
"           start gvim -S C:\project.vim
"
"      save it as "open_project.bat".
"      But I don't know how to write the windows "right-mouse" menu script,
"   so make yourself! I would be pleasure to help you if you need any.
"
"   4) ATTENTION: please download these scripts from vim.org, 
"   which is needed by this script!
"
"           NERDTree, Taglist, Omnicompletion
"
"     More scripts you can download, just as you need!
"
"     Above all, "cscope", "ctags", "wc" executable programes are needed.
"   Windows OS users can get them from Internet. while Linux users, 
"   just run your system supported package installer, such as "apt-get"
"   or "Software Center". All these softwares are open and free.
"
"     However, "cscope" runs slowly in my windows machine, I have
"   moved my work from windows to linux. You can try it!
"
"   5) Colorscheme recommend: "desert" or "evening", it's beautiful, and
"   eye-protected.
"
"   6) Mapped Keys:
"   	<F8>u		: update the project
"   	<F8>c		: clear the project
"   	<F8>s		: save the project
"   	<F8>q		: quit the project, will ask you to save
"   	_wc		: counte lines for project source files
"   	<F7>		: open the project based directory
"   	<F5>		: open the current file's directory
"   	
"   7) Some more useful keys in Init_environment function, list here:
"   	<space>		: jump to definition
"	<Alt-Q>		: close the present window
"	<Ctrl-S>	: save the file
"	<Ctrl-V>	: paste the system clip, only work in insert mode
"	<Ctrl-C>	: copy to system clip, only work in visual mode
"	<F1>		: backward
"	<F2>		: forward
"	<F3>		: jump to previous item showed in quickfix window (:cp)
"	<F4>		: jump to next item showed in quickfix window (:cn)
"	<Ctrl-F5>	: Open quickfix window (:copen)
"	<F9>		: Toggle to show function list window (:TlistToggle)
"
"	`s		: search the cursor place symbol (cs find s)
"       `g		: search the cursor place gloabl definition
"       `c		: search which functions calling the cursor place function
"       `t		: search the cursor place text
"       `e		: search the cursor place egrep pattern text
"       `f		: search the cursor place file, will search path
"       `i		: search which file "#include" the current header file
"       `d		: search which functions being called by current function
"
"       -s		: execute ":cs find s ", waiting for user's typing
"       -g		: execute ":cs find g ", just as above
"	-c		: execute ":cs find c ", just as above
"       -t              : execute ":cs find t ", just as above
"       -e              : execute ":cs find e ", just as above
"       -f              : execute ":cs find f ", just as above
"       -i              : execute ":cs find i ", just as above
"       -d              : execute ":cs find d ", just as above
"
"
"   8) More work will be done in furture.
"
"
"   ++==**$$==--   2011-12-1  22:21  --==$$**==++
"
"-------------------------------------------------------------



"-------------------------------------------------------------
" Global variables
" Make sure this file loaded on the project base directory
" First Step, source "session" file
"-------------------------------------------------------------

if !exists("g:base_dir")
	let g:base_dir = getcwd()
endif

let g:session_file = g:base_dir . "/session.vim"
if filereadable(g:session_file)
	silent! execute "so " . g:session_file
endif

" Change to the directory
silent! execute "cd " . g:base_dir

"Only load the script once
if !exists("g:project_script") || g:project_script == 0
	echo "loading project.vim"
	let g:project_script = 1
else
	echo "project.vim has been loaded."
	finish
endif

let g:cscope_loaded = 0
let g:initialized = 0

"/ is common used
let g:cscope_file = g:base_dir . "/cscope.out"
let g:lines_count_file = g:base_dir . "/lines_count.txt"
let g:files_list = g:base_dir . "/files.list"

" tags files contains some information about completion
let g:tags_file = g:base_dir . "/tags"

" env.vim stores some settings for this project, such as include's dir, etc.
let g:env_file = g:base_dir . "/env.vim"
if !filereadable(g:env_file)
	call writefile(["let g:include_dirs = [\"./include\",]"], g:env_file)
endif

execute "so " . g:env_file

if !exists("g:include_dirs")
	let g:include_dirs = [g:base_dir . "/include", "./include"]
elseif g:include_dirs != [] || g:include_dirs != [""]
	let i = 0
	for n in g:include_dirs
		if g:include_dirs[i] =~ "^\\."
			let g:include_dirs[i] = substitute(g:include_dirs[i], "^\\.", "", "e")
			let g:include_dirs[i] = g:base_dir . g:include_dirs[i]
		endif
		let i += 1
	endfor
endif

silent! execute "set path=.," . g:base_dir
for dir in g:include_dirs
	silent! execute "set path+=" . dir
endfor

if has("unix")
	silent! execute "set path+=/usr/include"
endif

silent! execute "set tags+=" . g:tags_file

let s:tags_cmd = "!ctags -L " . g:files_list . " --c++-kinds=+p --fields=+iaS --extra=+q -f " . g:tags_file
let g:cscope_cmd = "!cscope -b -q -k -i "


"--------------------------------------------------------------------
"     START PROJECT FUNCTIONS AND VARIABLES, This will overlap your vimrc file
"--------------------------------------------------------------------
func! Init_environment()
	"使用空格来跳转
	noremap <space> <C-]>zz
	noremap <m-q> <C-W>c
	noremap <C-S> :w<CR>
	inoremap <C-S> <C-O>:w<CR>
	inoremap <C-V> <C-O>"+p
	vnoremap <C-C> "+y

	nmap <F1> <C-O>
	nmap <F2> <C-I>
	nmap <F3> :cp<CR>
	nmap <F4> :cn<CR>
	nmap <C-F5> :copen<CR>
	nmap <2-LeftMouse> <C-]>

	"Tlist settings
	let g:Tlist_Use_Right_Window=1
	let g:Tlist_Show_One_File = 1
	let g:Tlist_Exit_OnlyWindow = 1
	nmap <F9> :TlistToggle<CR>

	"Cscope Setting, remove something from vim advice...
	if has("cscope")
		set csprg=cscope
		set csto=0
		set cst
		set nocsverb
		set cscopequickfix=s-,c-,d-,i-,t-,e-
		set csverb
	endif

	"searching before find
	nmap `s /\<<C-R><C-W>\><CR>:cs find s <C-R><C-W><CR>
	nmap `g /\<<C-R><C-W>\><CR>:cs find g <C-R><C-W><CR>
	nmap `c /\<<C-R><C-W>\><CR>:cs find c <C-R><C-W><CR>
	nmap `t /\<<C-R><C-W>\><CR>:cs find t <C-R><C-W><CR>
	nmap `e /\<<C-R><C-W>\><CR>:cs find e <C-R><C-W><CR>
	nmap `f :cs find f <C-R>=expand("<cfile>")<CR><CR>
	nmap `i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	nmap `d /\<<C-R><C-W>\><CR>:cs find d <C-R><C-W><CR>

	"typing faster.."
	nmap -s :cs find s 
	nmap -g :cs find g 
	nmap -c :cs find c 
	nmap -t :cs find t 
	nmap -e :cs find e 
	nmap -f :cs find f 
	nmap -i :cs find i 
	nmap -d :cs find d 

	"set cursorline
	set autochdir
	set number
	set ruler
	set hlsearch
	set incsearch
	set fencs=ucs-bom,utf-8,gbk,gbk18030,default,latin1
	set ffs=unix,dos
	"set guifont=
	syntax enable
	syntax on
	set showcmd
	set notimeout
	set autochdir
	set hlsearch
	set incsearch
	filetype on
	filetype plugin indent on
	"colorscheme desert
endfunc

"function! Toggle_QFW()
"    if exists("g:qfw_opened") && g:qfw_opened == 1
"        cclose
"        unlet g:qfw_opened
"    else
"        copen
"        let g:qfw_opened = 1
"    endif
"endfunction

"func! Search_in_files(files_list, pattern)
"	 let filename = a:files_list
"	 if filereadable(filename)
"		 let list=readfile(filename)
"		 let lines=join(list, ' ')
"		 silent execute 'grep ' . a:pattern . ' ' . lines
"	 endif
"endfunc

"call Search_in_files('file.list', 'BLOWFISH')


"Count lines for whole project
func! Count_project_lines(project_base_dir, files_list)
	if a:project_base_dir != '' && isdirectory(a:project_base_dir) && filereadable(a:files_list)
		let list = readfile(a:files_list)
		let pwd = getcwd()
		silent! execute "cd " . a:project_base_dir
		if filereadable(g:lines_count_file)
			call delete(g:lines_count_file)
		endif
		if 1
			let i = 0
			let wc_cmd = "!wc -l "
			for filename in list
				let i += 1
				let wc_cmd = wc_cmd . filename . " "
				"change more to test it?
				if i == 400
					silent! execute wc_cmd . " >> " . g:lines_count_file
					let wc_cmd = "!wc -l "
					let i = 0
				endif
			endfor
			if i != 0
				silent! execute wc_cmd . " >> " . g:lines_count_file
			endif
		else
			"when files too much, it will not work, use the above
			echo "Preparing to make the command..."
			let str = join(list, " ")
			let wc_cmd = "!wc -l " . str
			echo "Now starting to count lines..."
			silent! execute wc_cmd . "> " . g:lines_count_file
		endif
		echo "Success to generate code lines! See " . g:lines_count_file . "!"
		silent! execute "cd " . pwd
	endif
endfunc

" This is not useful
func! Project_buffer_add(project_base_dir, files_list)
	if a:project_base_dir != '' && isdirectory(a:project_base_dir) && filereadable(a:files_list)
		let list = readfile(a:files_list)
		for filename in list
			let filename = substitute(filename, "^.", "", "e")
			let filename = a:project_base_dir . filename
			silent! execute "badd " . filename
		endfor
	endif
endfunc

"Creating cscope files
func! CSCOPE_FILES(project_base_dir, files_list)
	let pwd = getcwd()
	if a:project_base_dir != '' && isdirectory(a:project_base_dir)
		silent! execute "cd " . a:project_base_dir
	else 
		return
	endif
	if filereadable(a:files_list)
		let lines = readfile(a:files_list)
			if lines != []
			"Should delete or not?
			"if filereadable(g:cscope_file)
			"	echo "Delete the old cscope.out file."
			"	call delete(g:cscope_file)
			"endif
			echo "Building cscope.out..."
			"silent! execute g:cscope_cmd . a:files_list
			" In windows, -q seems do nothing..., try to use it under
			" linux
			silent! execute g:cscope_cmd . a:files_list
			echo "Cscope.out has been created!"
		endif
	endif
	silent! execute "cd " . pwd
endfunc

"Creating tags files
func! CTAGS_FILES(project_base_dir, files_list)
	if a:project_base_dir != '' && isdirectory(a:project_base_dir) && filereadable(a:files_list)
		if filereadable(g:tags_file)
			echo "Delete the old tags file."
			call delete(g:tags_file)
		endif
		let pwd = getcwd()
		silent! execute "cd " . a:project_base_dir
		echo "Building tags..."
		silent! execute s:tags_cmd
		silent! execute "cd " . pwd
		echo "Tags file has been created!"
	endif
endfunc

" Must be not the absolute path
func! Get_project_files(project_base_dir)
	if a:project_base_dir != ''
		echo "Searching in the project directory for source files..."
		let filelist = expand(a:project_base_dir . '/**/*.[ch]')
		let file_list = split(filelist, "\n")
		" TODO try to confirm the file's permission
		return file_list
	else
		return []
	endif
endfunc

"Update the project...
fun! Update_project(project_base_dir)
	if a:project_base_dir != '' && isdirectory(a:project_base_dir)
		echo "Preparing for updating the project..."
		let pwd = getcwd()
		let files = g:files_list
		silent! execute "cd " . a:project_base_dir
		let filelist = Get_project_files('.')
		"Add all files to buffer list
		"call Project_buffer_add(a:project_base_dir, files)
		"setlocal noautochdir
		if writefile(filelist, files) == 0
			call CSCOPE_FILES('.', files)
			call CTAGS_FILES('.', files)
			"echo "Waiting ..."
			"while !filereadable(g:cscope_file) || !filereadable(g:tags_file)
			"	echon "."
			"	sleep
			"endwhile
			"echon "\n"
			if g:cscope_loaded == 1
				echo "Update project successfully!"
			else
				execute "cs add " . g:cscope_file . " " . g:base_dir
				let g:cscope_loaded = 1
			endif
			silent! execute "cs reset"
		else
			echo "Failed to update project!"
		endif
		silent! execute "cd " . pwd
	else
		echo "Nothing to do with updating project!"
	endif
endfunc

"Clear the project...
func! Clear_project()
	let pwd = getcwd()
	silent! execute "cd " . a:project_base_dir
	echo "Clearing the project..."
	if filereadable(g:files_list)
		call delete(g:files_list)
	endif
	if filereadable(g:cscope_file)
		cs kill 0
		let g:cscope_loaded = 0
		call delete(g:cscope_file)
		silent! call delete(g:base_dir . "/cscope.in.out")
		silent! call delete(g:base_dir . "/cscope.po.out")
	endif
	if filereadable(g:lines_count_file)
		call delete(g:lines_count_file)
	endif
	if filereadable(g:tags_file)
		call delete(g:tags_file)
	endif
	if filereadable(g:session_file)
		call delete(g:session_file)
	endif
	if filereadable(g:env_file)
		call delete(g:env_file)
	endif
	echo "Done!"
	silent! execute "cd " . pwd
endfunc

"Searching the files in the files.list file
func! Search_in_project()
	if filereadable(g:files_list)
		let file_list = readfile(g:files_list)
		let filename = input("Searching for file:")
		if filename != ""
			let searched = ['Select your wanted file:']
			let searched2 = ['null']
			let i = 0
			for line in file_list
				let str=matchstr(line, filename)
				if str != ''
					let i += 1
					call add(searched, i . '. ' . line)
					call add(searched2, line)
				endif
			endfor
			if i > 1
				let n = inputlist(searched)
			else
				let n = i
			endif
			if n != 0
				let searched_file = substitute(searched2[n], "^\.", "", "e")
				silent! execute 'vsp ' . g:base_dir . searched_file
			else
				echo "No result!"
			endif
		else
			echo "Empty file name!"
		endif
	else
		call Update_project(g:base_dir)
		echo "Try again!"
	endif
endfunc

"Searching files with cs command
func! Search_in_project2()
	"Can use <C-_> + c, d, etc
	if filereadable(g:cscope_file)
		let filename = input("Searching for file:")
		if filename != ""
			"find definition
			execute "cs find f " . filename
		else
			echo "Empty file name!"
		endif
	else
		call Update_project(g:base_dir)
		echo "Try again!"
	endif
endfunc

"Searching func definition with cs command
func! Search_func_in_project()
	"Can use <C-_> + c, d, etc
	if filereadable(g:cscope_file)
		let funcname = input("What function do you want to get?")
		if funcname != ""
			"find definition
			execute "cs find g " . funcname
		else
			echo "Empty function name!"
		endif
	else
		call Update_project(g:base_dir)
		echo "Try again!"
	endif
endfunc

"Init project 
func! Init_project()
	" Initialize the environment...
	call Init_environment()
	" Initialize the project ...
	" 
	" Open the directory
	if 1
		silent! execute "NERDTree " . g:base_dir
	endif
	silent! execute "normal \<C-W>l"
	"Add cscope.out file
	if filereadable(g:cscope_file)
		if g:cscope_loaded == 0
			silent! execute "cs add " . g:cscope_file . " " . g:base_dir
			let g:cscope_loaded = 1
		endif
	else
		call Update_project(g:base_dir)
	endif

	if filereadable(g:files_list)
		"call Project_buffer_add(g:base_dir, g:files_list)
	endif
	if !filereadable(g:tags_file)
		call CTAGS_FILES(g:base_dir, g:files_list)
	endif
	echo "Successful to open the project!"
endfunc

"Close the project, which will prompt to ask you whether to save the project.
func! Save_project()
        let save = input("Need to save this session [y/n]? Press enter to discard the action, else save it: ")
        if save != 'n' && save != ''
                confirm wall
                if 1
                        NERDTreeClose
                endif
                execute "mksession! " . g:session_file
                if 1
                        NERDTree
                endif
        endif
endfunc

func! Close_project()
	let quit = input("Would you like to quit[y]? Press y or enter to exit: ")
	if quit != 'y' && quit != ''
		echo "Quit canceled."	
	else
                call Save_project()
		confirm qa
	endif
endfunc

"TODO, simulate the source insight
func! Files_list_window()
	if filereadable(g:files_list)
		let lines = readfile(g:files_list)
		for n in lines
			let n = simplify(n)
		endfor
	endif
endfunc

if g:initialized == 0
	call Init_project()
	let g:initialized = 1
else
	echo "Do not initialize twice."
endif

"Mapped key
"
"
" update 
noremap <F8>u :call Update_project(g:base_dir)<cr>
" Searching , obsolete
"noremap <F8>f:call Search_in_project2()<cr>
"noremap <F8>g :call Search_func_in_project()<cr>
" Clear
noremap <F8>c :call Clear_project()<cr>
" Close(quit)
noremap <F8>q :call Close_project()<cr>
noremap <F8>s :call Save_project()<cr>
" Open the project base directory
noremap <F7>	:NERDTree <C-R>=g:base_dir<CR><CR>
" Open the current directory
noremap <F5>	:NERDTreeToggle<CR>
" Count lines
nmap <silent> _wc :call Count_project_lines(g:base_dir, g:files_list)<cr>

" Create a menu called Project, see preview, please use it.
menu Project.Update :silent call Update_project(g:base_dir)<cr>
menu Project.Clear  :silent call Clear_project()<cr>
menu Project.Quit   :call Close_project()<cr>
menu Project.Save   :call Save_project()<cr>
menu Project.Toggle\ Symbols\ List :TlistToggle<cr>
menu Project.Open\ Project\ Directory :NERDTree <C-R>=g:base_dir<cr><cr>
menu Project.Open\ Current\ Directory :NERDTree <C-R>=getcwd()<cr><cr>
menu Project.Count\ Project\ Lines      :call Count_project_lines(g:base_dir, g:files_list)<cr>

