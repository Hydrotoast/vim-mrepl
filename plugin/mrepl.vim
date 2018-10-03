function! s:ReplBind(repl_bufname) abort

  " Get the buffer number of the REPL.
  let repl_buf_nr = bufnr(a:repl_bufname)

  " Get the channel of the REPL.
  execute 'b' . repl_buf_nr
  let repl_channel_id = &channel
  execute 'b#'

  if repl_channel_id == 0
    echoerr 'Failed to bind to a terminal. '
          \ . 'The selected buffer is not a terminal.'
    return
  end

  " Bind the REPL to the source buffer.
  let b:repl_channel_id = repl_channel_id

endfunction

function! s:ReplSendLine(...) abort

  if !exists('b:repl_channel_id')
    echoerr 'Failed to send line to the terminal. '
          \ . 'The terminal is not bound. '
          \ . 'Use ReplBind <repl_bufname> to bind the terminal.'
    return
  end

  " Get the current REPL mode.
  let repl_mode = ReplModeGetCurrent()

  " Get the current line from the source buffer.
  let payload = getline(line('.'))

  " Prepare the frame.
  let frame = repl_mode.line.header . payload . repl_mode.line.footer

  " Send the frame to the REPL.
  call chansend(b:repl_channel_id, frame)

endfunction

function! s:ReplSendBlock(...) abort range

  if !exists('b:repl_channel_id')
    echoerr 'Failed to send block to the terminal. '
          \ . 'The terminal is not bound. '
          \ . 'Use ReplBind <repl_bufname> to bind the terminal.'
    return
  end

  " Get the current REPL mode.
  let repl_mode = ReplModeGetCurrent()

  " Get the visually selected lines in the source buffer.
  let lines = getline(a:firstline, a:lastline)
  let payload = join(lines, "\n") . "\n"

  " Prepare the frame.
  let frame = repl_mode.block.header . payload . repl_mode.block.footer

  " Send the frame to the REPL.
  call chansend(b:repl_channel_id, frame)

endfunction

function! s:ReplCompleteTerminalNames(A, P, L)

  " Retrieve the terminal names from the registry.
  return TerminalRegistryListNames()
endfunction

" Binds a REPL to the current buffer by the buffer name of the REPL.
command! -nargs=1 -complete=customlist,<SID>ReplCompleteTerminalNames ReplBind
      \ call <SID>ReplBind(<q-args>)

" Sends a line to the bound REPL.
command! ReplSendLine
      \ call <SID>ReplSendLine()

" Sends a block to the bound REPL.
command! -range ReplSendBlock
      \ <line1>,<line2>call <SID>ReplSendBlock()

" Default mappings.
nnoremap <silent> <leader>rb :ReplBind 
nnoremap <silent> <leader>re :ReplSendLine<CR>
vnoremap <silent> <leader>re :ReplSendBlock<CR>

