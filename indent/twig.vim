if exists("b:ran_once")
	finish
endif

let b:ran_once = 1

setlocal indentexpr=GetTwigIndent()

fun! GetTwigIndent()
	let currentLineNumber = v:lnum
	let currentLine = getline(currentLineNumber)
	let previousLineNumber = prevnonblank(currentLineNumber - 1)
	let previousLine = getline(previousLineNumber)

	if (previousLine =~ s:startStructures || previousLine =~ s:middleStructures) && (currentLine !~ s:endStructures && currentLine !~ s:middleStructures)
		echo "below start or middle"
		return indent(previousLineNumber) + &shiftwidth
	elseif currentLine =~ s:endStructures || currentLine =~ s:middleStructures
		let previousOpenStructureNumber = s:FindPreviousOpenStructure(0, 0, currentLineNumber)
		let previousOpenStructureLine = getline(previousOpenStructureNumber)
		echo "finding previous open structure"
		return indent(previousOpenStructureNumber)
	endif

	echo "none"

	return HtmlIndent()
endf


function! s:FindPreviousOpenStructure(countOpen, countClosed, lineNumber)
	echo a:countOpen . a:countClosed . a:lineNumber
	if a:countOpen > a:countClosed
		return a:lineNumber
	elseif a:lineNumber <= 0
		return 0
	endif

	let currentLineNumber = a:lineNumber - 1
	let currentLine = getline(currentLineNumber)
	if currentLine =~ s:startStructures
		return s:FindPreviousOpenStructure(a:countOpen + 1, a:countClosed, currentLineNumber)
	elseif currentLine =~ s:endStructures
		return s:FindPreviousOpenStructure(a:countOpen, a:countClosed + 1, currentLineNumber)
	else
		return s:FindPreviousOpenStructure(a:countOpen, a:countClosed, currentLineNumber)
	endif

endfunction

function! s:StartStructure(name)
	return '{%\s*' . a:name . '.*%}'
endfunction

function! s:EndStructure(name)
	return '{%\s*end' . a:name . '.*%}'
endfunction

function! s:Map(Fun, list)
    if len(a:list) == 0
        return []
    else
        return [a:Fun(a:list[0])] + s:Map(a:Fun, a:list[1:])
    endif
endfunction

fun! s:BuildStructures()
	let structures = ['if','for','block']
	let mStructures = ['elseif','else']
	let s:startStructures = join(s:Map(function('s:StartStructure'), structures), '\|')
	let s:endStructures = join(s:Map(function('s:EndStructure'), structures), '\|')
	let s:middleStructures = join(s:Map(function('s:StartStructure'), mStructures), '\|')
	let s:allStructures = '{%.*%}'
endfun

call s:BuildStructures()
