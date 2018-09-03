class Dashing.Health extends Dashing.Widget
  onData: (data) ->
    $(@get('node')).css('background-color', data.color)

    if @get('status') == true
      $(@get('node')).find('.health-icon').html('&#10003;')
    else
      $(@get('node')).find('.health-icon').html('&#10005;')
