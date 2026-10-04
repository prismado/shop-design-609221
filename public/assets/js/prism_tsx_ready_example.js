	$(document).ready(function(){
		var msg = 'ok';
		if (jQuery.fn.jquery != '3.4.1') {
			msg = 'Erwartung war 3.4.1';
		}
		document.getElementById('div81_307071').innerHTML='<code>jQuery ist aktiv; Version: ' + jQuery.fn.jquery + '</code> ' + msg;
	});
