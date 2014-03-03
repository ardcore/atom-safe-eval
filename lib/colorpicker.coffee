ColorpickerView = require './colorpicker-view'

module.exports =
  colorpickerView: null

  activate: (state) ->
    @colorpickerView = new ColorpickerView(state.colorpickerViewState)

  deactivate: ->
    @colorpickerView.destroy()
