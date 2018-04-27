# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  console.log("hello")
  $ ->
    $.getJSON "http://localhost:3000/api/v2/chart/get_chart_data.json?api_token=2_-yCD0x0z2U--Afv3ULTw", (chart_data) ->
      console.log("url json data", chart_data)
      $('#twitter_shares').highcharts
        chart: type: 'area', zoomType: 'x'
        title: text: 'Incremental Twitter Shares Over Time'
        xAxis: type: 'datetime'
        yAxis: title: text: 'Daily Volume of Shares'
        series: [chart_data]