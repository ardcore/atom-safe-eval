vm = require 'vm'

{View} = require 'atom'

module.exports =
class EvalView extends View
  @content: ->
    @div class: 'eval overlay from-bottom', =>
      @pre outlet: 'eval_output', class: 'code', 'code'
      @span class: 'text-subtle', =>
        @span 'execution time:'
        @span outlet: 'time_output'
        @span 'ms'

  initialize: (serializeState) ->
    atom.workspaceView.command "eval:run", => @run()
    @subscribe atom.workspaceView, "cursor:moved", => @hide()

  destroy: ->
    @detach()

  run: ->
    result = ""
    isValid = true
    @eval_output.html("").removeClass("text-success", "text-error")
    selections = atom.workspace.activePaneItem.getSelections()
    code = (selection.getText() for selection in selections)
    if Array.isArray code
      code = code.join("\n")

    code = code.trim()
    startTime = Date.now()
    try
      result = vm.runInNewContext code, {}, 'evaluated script'

    catch error
      result = error
      isValid = false

    endTime = Date.now()
    deltaTime = endTime - startTime
    result = String( result )

    if result
      @eval_output.html result
      @time_output.html deltaTime
      @eval_output.addClass if isValid then "text-success" else "text-error"
      atom.workspaceView.append(this)

  hide: ->
    if @hasParent()
      @detach()
