<!DOCTYPE html>
<?php 
	$mysqli = new mysqli(ini_get("mysqli.default_host"), ini_get("mysqli.default_user"), ini_get("mysqli.default_pw"), "dnssecfight");
	$result = $mysqli->query("select hoster from secure_delegation order by day desc, num desc limit 10");
	$hosters_data = "";
	while ($row = $result->fetch_assoc()) {
		$hoster = $mysqli->real_escape_string($row["hoster"]);

		$hoster_result = $mysqli->query("select unix_timestamp(day) * 1000 as day, num from secure_delegation where hoster = '$hoster' and day > date_add(now(), interval -2 month) order by day");
		$hoster_graph = "";
		while ($hoster_row = $hoster_result->fetch_assoc()) {
			if ($hoster_graph != "") {
				$hoster_graph .= ", ";
			}
			$hoster_graph .= "[ " . $hoster_row["day"] . ", " . $hoster_row["num"] . " ]";
		}

		if ($hosters_data == "") {
			$hosters_data = "var series = [ { label: '$hoster', data: [ $hoster_graph ] }";
		} else {
			$hosters_data .= ", { label: '$hoster', data: [ $hoster_graph ] }";
		}
	}

	$hosters_data .= " ];";
?>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>DNSSEC operator fight</title>

		<link href="/css/bootstrap.min.css" rel="stylesheet">
		<script type="text/javascript" src="/js/bootstrap.min.js"></script>
		<script type="text/javascript" src="/js/jquery-1.8.0.min.js"></script>
		<script type="text/javascript" src="/js/flot/jquery.flot.min.js"></script>
	</head>

	<body>
		<h2>DNSSEC operator fight</h2>

		<a href="https://github.com/atomia/dnssecfight"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_red_aa0000.png" alt="Fork me on GitHub"></a>

		<div id="graph" style="width:90%;height:700px;"></div>

		<script type="text/javascript">
			<?php echo $hosters_data; ?>

			$.plot($("#graph"), series, {
				xaxis: { mode: "time" },
				yaxis: {
					transform: function (v) { return Math.log(v); },
					inverseTransform: function (v) { return Math.exp(v); },
					min: 1,
					ticks: 5
				},
				legend: { position: "se" },
				series: {
					points: { show: true, fill: false },
					lines: { show: true, fill: false }
				},
				grid: { hoverable: true }
			});

			// Shamelessly stolen from people.iola.dk/olau/flot/examples/interacting.html
			function showTooltip(x, y, contents) {
				$('<div id="tooltip">' + contents + '</div>').css( {
					position: 'absolute',
					display: 'none',
					top: y + 5,
					left: x + 5,
					border: '1px solid #fdd',
					padding: '2px',
					'background-color': '#fee',
					opacity: 0.80
				}).appendTo("body").fadeIn(200);
			}
		
			var previousPoint = null;
			$("#graph").bind("plothover", function (event, pos, item) {
				$("#x").text(pos.x.toFixed(2));
				$("#y").text(pos.y.toFixed(2));
		
				if (item) {
					if (previousPoint != item.dataIndex) {
						previousPoint = item.dataIndex;
						
						$("#tooltip").remove();
						var x = item.datapoint[0].toFixed(2),
							y = item.datapoint[1].toFixed(2);
						
						showTooltip(item.pageX, item.pageY,
									item.series.label + " had " + parseInt(y) + " signed zones at " + new Date(parseInt(x)).toDateString());
					}
				}
				else {
					$("#tooltip").remove();
					previousPoint = null;			
				}
			});

		</script>
	</body>
</html>
