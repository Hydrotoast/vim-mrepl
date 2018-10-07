" Encapsulate the terminal registry within the script.
if !exists('s:registry')
  let s:registry = {}
end


" Returns the list of buffer names of active terminals in the registry.
function! TerminalRegistryListNames()
  return map(values(s:registry), {k, v -> v.bufname}) 
endfunction


" Gets the channel id of an active terminal by its buffer number.
function! TerminalRegistryGetChannelId(term_bufnr)

  " Fail if the terminal buffer number is not in the registry.
  if !has_key(s:registry, a:term_bufnr)
    echoerr "Failed to get the channel id from the registry. "
          \ . "Invalid term_bufnr=" . a:term_bufnr
    return
  end

  s:registry[a:term_bufnr]
endfunction


function! s:Add(term_bufname)

  " Get the terminal attributes.
  let term_bufnr = bufnr(a:term_bufname) 

  " Fail if the buffer does not exist.
  if term_bufnr == -1
    echoerr "Failed to add terminal to the registry. "
          \ . "The buffer does not exist."
    return
  end

  let term_channel_id = &channel

  " Fail if the terminal is not open.
  if !term_channel_id
    echoerr "Failed to add terminal to the registry. There is no channel."
    return
  end

  " Add the terminal to the regstry.
  let s:registry[term_bufnr] = {}
  let s:registry[term_bufnr].channel_id = term_channel_id
  let s:registry[term_bufnr].bufname = a:term_bufname
endfunction


function! s:Remove(term_bufname)

  " Get the buffer number of the terminal that closed.
  let term_bufnr = bufnr(a:term_bufname) 

  " Fail if the buffer does not exist.
  if term_bufnr == -1
    echoerr "Failed to add terminal to the registry. "
          \ . "The buffer does not exist."
    return
  end

  " Remove the closed terminal.
  call remove(s:registry, term_bufnr)
endfunction


" Listen for terminals that are opened and closed.
augroup terminal_registry_listeners
  autocmd!

  autocmd TermOpen * call <SID>Add(expand('<afile>'))
  autocmd TermClose * call <SID>Remove(expand('<afile>'))
augroup END

