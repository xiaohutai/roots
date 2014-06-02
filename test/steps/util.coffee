Roots   = require("../../")
When    = require("when")
path    = require("path").resolve(__dirname, 'rage')
rimraf  = require("rimraf")
Server = require("../../lib/local_server")
watcherInstance = null
server = null
on_error = (cli, server, err) -> server.show_error(Error(err).stack)
on_start = (cli, server) -> server.compiling()
on_done = (cli, server) -> server.reload()

module.exports = ->
  @After ->
    server.stop()
    When.Promise (resolve) ->
      rimraf path, -> resolve()

  @Given /^I have a roots project$/, ->
    Roots.new(
      path: path
      overrides:
        name: "doge-hunter"
        description: "data love geordi"
    )

  @Given /^I am watching it$/, ->
    _this = this

    return When.Promise (resolve) ->
      project = new Roots(path)
      server  = new Server(project, project.root)
      watcher = project.watch()
      cli     = {}

      server.start(1111)
      project.on('start', on_start.bind(null, cli, server))
      project.on('error', on_error.bind(null, cli, server))
      project.on('done', on_done.bind(null, cli, server))

      watcher.then (watcherInstance) ->
        _this.driver.get("http://127.0.0.1:1111/").then -> resolve()
