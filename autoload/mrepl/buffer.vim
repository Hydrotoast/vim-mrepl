function! mrepl#buffer#Bind(repl_bufname) abort

  " Get the buffer number of the REPL.
  let repl_buf_nr = bufnr(a:repl_bufname)

  " Get the channel of the REPL.
  let repl_channel_id = getbufvar(repl_buf_nr, '&channel')

  if repl_channel_id == 0
    echo 'The selected buffer is not a terminal.'
    return
  end

  " Bind the REPL to the source buffer.
  let b:repl_channel_id = repl_channel_id
endfunction


function! mrepl#buffer#EvalSelection(selection) abort

  if !exists('b:repl_channel_id')
    echo 'The buffer is not bound to a terminal. '
          \ . 'Use :ReplBind {repl_bufname} to bind the buffer.'
    return
  end

  " Choose the format type based on whether the selection has a newline.
  let has_newline = stridx(a:selection, "\n") != -1
  let format_type = has_newline ? 'block' : 'line'

  " Prepare the frame.
  let repl_mode = <SID>GetMode()
  let format = repl_mode[format_type]
  let frame = format.header . a:selection . format.footer

  " Send the frame to the REPL.
  call chansend(b:repl_channel_id, frame)
endfunction


function! mrepl#buffer#SwitchMode(mode) abort

  if !mrepl#modes#Exists(a:mode)
    echo 'The mode has {' . a:mode . '} not been registered.'
    return
  end

  let b:repl_mode = a:mode
endfunction


" Return the REPL mode protocol.
function! s:GetMode()
  if !exists('b:repl_mode')
    let b:repl_mode = "term"
  end
  return mrepl#modes#Get(b:repl_mode)
endfunction

