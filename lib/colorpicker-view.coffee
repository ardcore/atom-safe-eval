colorjoe = require 'colorjoe'
onecolor = require 'onecolor'

{View} = require 'atom'

module.exports =
class ColorpickerView extends View
  @content: ->
    @div class: 'colorpicker overlay floating', =>
      @div outlet: "picker", ""
      @div class: 'buttons', =>
        @a outlet: "buttonCancel", class: 'btn cancel', click: 'hide', "cancel"
        @a outlet: "buttonConfirm", class: 'btn btn-success confirm hidden', click: "confirm", "confirm"

  initialize: (serializeState) ->
    atom.workspaceView.command "colorpicker:show", => @show()

  destroy: ->
    @detach()

  attachColorPicker: (initText) ->
    atom.workspaceView.append(this) # TODO: move to end
    changed = false
    if not @colorPicker
      @colorPicker = colorjoe.rgb @picker.get()[0], initText || "#000000",
      ['currentColor', ['fields': {space: 'HSL', limit: 255, fix: 0}], 'hex']
      @colorPicker.on "change", (color) =>
        if !changed
          @buttonConfirm.removeClass('hidden')

        changed = true

      @colorPicker.on "done", (color) =>
        @selectedColor = color

  show: ->
    editor = atom.workspace.activePaneItem
    selections = editor.getSelections()
    candidate = null
    isValid = true

    if selections.length == 1 and not selections[0].getText()
      editor.transact =>
        editor.selectWord()
        word = editor.getSelection().getText()

        candidate = onecolor(word)
        if candidate not instanceof onecolor.RGB and
           candidate not instanceof onecolor.HSL and
           candidate not instanceof onecolor.HSV
          isValid = false
          editor.abortTransaction()

    else
      word = editor.getSelection().getText()
      candidate = onecolor(word)
      if candidate not instanceof onecolor.RGB and
         candidate not instanceof onecolor.HSL and
         candidate not instanceof onecolor.HSV
        isValid = false

    @attachColorPicker if isValid then editor.getSelection().getText() else null


  hide: ->
    if @hasParent()
      @detach()

  confirm: ->
    @insertColor @selectedColor
    @hide()

  insertColor: (color) ->
    editor = atom.workspace.activePaneItem
    selections = editor.getSelections()
    editor.transact =>
      selection.insertText color.hex().slice(1) for selection in selections
