# PixelEmConverter
 
 * this can be installed with Vim Plug by doing the following:
   * ``` Plug 'joedbenjamin/pixelemconverter' ```
 * this is a plugin to do the calculations when converting pixels to em and vice versa.
 * If you decide to use this plugin, there are some default mappings but they can be overwritten.
 * Conversions work in normal and insert mode
 * When you use your key mapping, it will wait for you to put a number in and once you do and hit enter, the calculated value will appear where your cursor is.
 * You can override the following by putting the values in your vimrc file
   * ``` let g:default_pixel_user = 10 ``` default pixel value
   * ``` let g:pixel2em_map_keys_user = <leader>pe ``` - mapping to convert from pixels to em
   * ``` let g:em2pixel_map_keys_user = <leader>ep ``` - mapping to convert from em to pixels
 * ```<leader>pe``` - default mapping to convert from pixels to em
 * ```<leader>ep``` - default mapping to convert from em to pixels
 * You can also change the default pixel value by calling the following command like below
   * ``` :SetDefaultPixel 20 ```

<br/>

# How I built my first Vim Plugin?

## I use [Vim-Plug](https://github.com/junegunn/vim-plug) to handle my plugins

 * Vim-Plug can load your local plugins by supplying the local path like below
   * This will allow you to develop your plugin outside of the directory Vim-Plug uses to manage its plugins 
   * Lets test this out
     * Create a folder where you will like to create your plugin, for this plugin I am calling mine pixelemconverter
     * Create a subfolder inside of the pixelemconverter directory by the name of plugin
     * Create a file inside of the plugin folder by the name of pixelemconverter.vim or whatever you would like to call it
      ```
        └── pixelemconverter
                 └── plugin
                       └── pixelemconverter.vim
      ```
     * Update your vimrc file to include the Plug with the path of the plugin where somepath and someotherpath is just random text but your path will be the actual path of the plugin
     * ``` Plug '~/somepath/someotherpath/pixelemconverter' ```
     * **You must** source your .vimrc file or restart vim to get it working

<hr>

## Testing if the plugin is active
 
 * Lets first write a simple command to make sure its working
   * Put the below code in the pixelemconverter.vim file and save it
   * ``` nnoremap <leader>99 :echo "hello"<cr> ```
   * **You must** source your .vimrc file or restart vim to get it working
   * If you are confused by the mapping, let me explain.
     * nnoreamp - we are setting up a mapping in normal mode to keep it simple
     * ```<leader>``` - is a key that is set in your vimrc file like this ``` :let mapleader = "," ``` - with the setting you see here, I am telling vim that anytime you see ```<leader>```, it means a comma ```,```
     * ```<leader>99``` means we are about to map something to these keys
     * ```:echo "hello"\<cr>``` - all this does is echo hello, keep in mind the ```<cr>``` at the end represents a carriage return
   * Now, if you hit the mapping which will be ```<leader>99```, meaning ```,99``` - you should see hello printed out
   * Lets take a step backwards for a sec, having to keep resourcing the .vimrc file w/o a shortcut or restarting vim gets old really quick.  Why dont we create a mapping for that if you don't already have one. You can put this in your .vimrc file and map it to the keys you want but I did it like below where ```$MYVIMRC``` is an environment variable which should be the location of your .vimrc file
     * ``` nnoremap <leader>vs :so $MYVIMRC<cr>```

<hr>

## Requirements

 * variables
   * These variables will be used in the plugin.
     * g:default_pixel_user
     * g:default_pixel = ```16```
     * g:pixel2em_map_keys_user
     * g:pixel2em_map_keys = ```<leader>pe```
     * g:em2pixel_map_keys_user
     * g:em2pixel_map_keys = ```<leader>ep```
  
  * The start of the file will have the following: this will set the user values if given or use default values.
    * ```vim
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

        if exists('g:default_pixel_user')
          let g:em2pixel_map_keys = g:em2pixel_map_keys_user
        else
          let g:em2pixel_map_keys = "<leader>ep"
        endif 
        ```

* functions
  * ```SetDefaultPixel(px)```
      ```vim
      function! SetDefaultPixel(px) abort
        let g:default_pixel = a:px
      endfunction
      ```
    * a function to set the default pixel value
  * ```PixelEmConverterHelper(value, isNormal, toType)```
      ```vim
      function! PixelEmConverter(value, isNormal, toType) abort
        if(a:toType ==? 'em')
          let result = a:value / (g:default_pixel * 1.0)
        elseif(a:toType ==? 'px')
          let result = a:value * g:default_pixel
        endif
        call PixelEmConverterHelper(result, a:isNormal, a:toType)
      endfunction
      ```
      * function takes 3 params
        * value - value to convert
        * isNormal - represents if it came from normal mode, else insert mode
        * toType - the type it is being converted to, either px or em
      * if toType is 'em'
        * if so calculate the em value by dividing the default pixel into the px value passed in
          * to make sure we get a decimal value and not have numbers rounded, times the default pixel by 1.0
      * if toType is 'px'
        * if so calcualte the px value by multiplying the default pixel by the em value passed in
      * call the PixelEmConverter function 

  * ```PixelEmConverter(value, isNormal, toType)```
      ```vim
      function! PixelEmConverterHelper(value, isNormal, toType) abort
        let rounded = round(a:value * 100) / 100
        let result = string(rounded).a:toType
        let cmd = "\<c-r>='".result."'\<cr>"
        if(a:isNormal == 1)
          execute 'normal! a'.cmd."\<esc>"
        else
          start
          call feedkeys(cmd)
        endif
      endfunction
      ```
      * function takes 3 params
        * value - converted value
        * isNormal - represents if it came from normal mode, else insert mode
        * toType - the type it is being converted to, either px or em
      * round the value to 2 decimal places
        * timing the value by 100 before its rounded and then divinding it by 100 put its at 2 decimal places
        * convert the value to a string and append the type to the end of it
        * create the cmd
        * if normal
          * execute the normal command by first going into insert mode then the command and back to normal mode
        * if insert
          * start - puts it in insert mode
          * feedkeys - will represent keys being pressed while in insert mode
            * i used feedkeys b/c was having an issue with the cursor position w/o doing it this way

* Create The Commands
  ```vim
    command! -nargs=1 SetDefaultPixel :call SetDefaultPixel(<q-args>)
    command! -nargs=1 Pixel2EmNormal :call PixelEmConverter(<q-args>, 1, 'em')
    command! -nargs=1 Pixel2EmInsert :call PixelEmConverter(<q-args>, 0, 'em')
    command! -nargs=1 Em2PixelNormal :call PixelEmConverter(<q-args>, 1, 'px')
    command! -nargs=1 Em2PixelInsert :call PixelEmConverter(<q-args>, 0, 'px')
  ```
* Mappings
  ```vim
    execute 'nnoremap '.g:pixel2em_map_keys.' :Pixel2EmNormal '
    execute 'inoremap '.g:pixel2em_map_keys.' <c-o>:Pixel2EmInsert '
    execute 'nnoremap '.g:em2pixel_map_keys.' :Em2PixelNormal '
    execute 'inoremap '.g:em2pixel_map_keys.' <c-o>:Em2PixelInsert '
  ```
