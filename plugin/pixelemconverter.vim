if exists('g:default_pixel_user')
  let g:default_pixel = g:default_pixel_user
else
  let g:default_pixel = 16
endif

if exists('g:pixel2em_map_keys_user')
  let g:pixel2em_map_keys = g:pixel2em_map_keys_user
else
  let g:pixel2em_map_keys = "<leader>pe"
endif

if exists('g:em2pixel_map_keys_user')
  let g:em2pixel_map_keys = g:em2pixel_map_keys_user
else
  let g:em2pixel_map_keys = "<leader>ep"
endif


function! SetDefaultPixel(px) abort
  let g:default_pixel = a:px
endfunction

function! PixelEmConverter(value, isNormal, toType) abort
  if(a:toType ==? 'em')
    let result = a:value / (g:default_pixel * 1.0)
  else
    let result = a:value * g:default_pixel
  endif
  call PixelEmConverterHelper(result, a:isNormal, a:toType)
endfunction

function! PixelEmConverterHelper(value, isNormal, toType) abort
  let rounded = round(a:value * 1000) / 1000
  let result = string(rounded).a:toType
  let cmd = "\<c-r>='".result."'\<cr>"
  if(a:isNormal == 1)
    execute 'normal! a'.cmd
  else
    start
    call feedkeys(cmd) 
  endif
endfunction

command! -nargs=1 SetDefaultPixel :call SetDefaultPixel(<q-args>)
command! -nargs=1 Pixel2EmNormal :call PixelEmConverter(<q-args>, 1, 'em')
command! -nargs=1 Pixel2EmInsert :call PixelEmConverter(<q-args>, 0, 'em')
command! -nargs=1 Em2PixelNormal :call PixelEmConverter(<q-args>, 1, 'px')
command! -nargs=1 Em2PixelInsert :call PixelEmConverter(<q-args>, 0, 'px')

execute 'nnoremap '.g:pixel2em_map_keys.' :Pixel2EmNormal '
execute 'inoremap '.g:pixel2em_map_keys.' <c-o>:Pixel2EmInsert '
execute 'nnoremap '.g:em2pixel_map_keys.' :Em2PixelNormal '
execute 'inoremap '.g:em2pixel_map_keys.' <c-o>:Em2PixelInsert '



