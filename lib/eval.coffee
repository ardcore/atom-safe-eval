EvalView = require './eval-view'

module.exports =
  evalView: null

  activate: (state) ->
    @evalView = new EvalView(state.evalViewState)

  deactivate: ->
    @evalView.destroy()
