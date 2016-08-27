{exec} = require 'child_process'
fs = require 'fs'
{CompositeDisposable} = require 'atom'

module.exports = ExecuteCommand =
   subscriptions: null

   config:
      command:
         type: 'string'
         default: 'run.cmd'
      showOutputNotifications:
         type: 'boolean'
         default: 'true'
      showErrorNotifications:
         type: 'boolean'
         default: 'true'
      muteNotificationRegex:
         type: 'string'
         default: ''

   activate: (state) ->

      # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
      @subscriptions = new CompositeDisposable

      # Register command that toggles this view
      @subscriptions.add atom.commands.add 'atom-workspace',
      'execute-command:execute': => @execute()

   deactivate: ->
      @subscriptions.dispose()

   execute: ->
      comName = atom.config.get 'execute-command.command'
      errorNt = atom.config.get 'execute-command.showErrorNotifications'
      outNt = atom.config.get 'execute-command.showOutputNotifications'
      mute = atom.config.get 'execute-command.muteNotificationRegex'
      com = comName

      # Execute the command
      console.log "Executing #{com}"
      exec com, (error, stdout, stderr)->
         if stderr? and errorNt
            if mute is "" or not RegExp(mute).test(stderr)
               atom.notifications.addWarning "Error while executing command", {detail: stderr, dismissable: true}
         if stdout? and outNt
            if mute is "" or not RegExp(mute).test(stdout)
               atom.notifications.addSuccess "Command Output", {detail: stdout, dismissable: true}
         if error?
            console.error "Fatal error while executing command:", error
