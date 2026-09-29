let elementCounter = 0;

class PrismDialogSR extends HTMLElement {
    constructor() {
	super();

	// Erstelle einen Shadow Root
	this.attachShadow({ mode: 'open' });

	// Attribute initialisieren
	this.prompt      = this.getAttribute('prompt');
	this.callback    = this.getAttribute('callback');
	this.referer     = this.getAttribute('referer') || '/';
	this.instruction = this.getAttribute('instruction');
	this.lang        = this.getAttribute('lang');
	this.timeout     = this.getAttribute('timeout') || 1250;
	this.css_id      = this.getAttribute('css_id')  || 'div404181_24';
	this.debug       = this.getAttribute('debug');

	const uniqueId = `myButton-${elementCounter++}`;

	// Erstelle einen Query String basierend auf speziellen Attributen
	let queryStringParts = [];
	Array.from(this.attributes).forEach(attr => {
	    if (attr.name.startsWith('x_')) {
		let encodedValue = encodeURIComponent(attr.value);
		queryStringParts.push(`${attr.name}=${encodedValue}`);
	    }
	});
	this.queryString = queryStringParts.join('&');

	// HTML Template definieren
	this.shadowRoot.innerHTML = `
	    <link rel="stylesheet" href="/assets/css/core.min.css">
	    <button class="btn btn-primary btn-sm btn-soft p-2 pt--0 pl--4 pr--4 pb--0" id="${uniqueId}">
		${this.prompt}
	    </button>
	`;
	this.buttonId = uniqueId;
    }

    connectedCallback() {
	// Event Listener fuer den Button hinzufuegen
	this.shadowRoot.querySelector(`#${this.buttonId}`).addEventListener('click', () => {
	    this.showDialog();
	});
    }

    disconnectedCallback() {
	// console.log("DN404221-51: disconnectedCallback buttonID " + this.buttonId);
    }

    showDialog() {
	// Implementiere eine Funktion, die benoetigt wird, um den Dialog zu zeigen
	// Hier muesstest du definieren, was passiert, wenn der Button geklickt wird
	    Swal.fire({
		title: this.prompt,
		input: 'text', // -- number
		inputLabel: this.instruction,
		inputPlaceholder: 'Wert hier eingeben',
		inputAttributes: { 'aria-label': '' },
		// -- 20Apr2024 (optional)
		customClass: {
			confirmButton: 'btn btn-sm w--150 btn-primary',
			cancelButton:  'btn btn-sm w--150 text-dark',
			container:     'custom-swal',
			title:         'fs--20 custom-swal-title',
			input:         'text-center',
			popup:         'custom-swal-pop'
		},
		showCancelButton:   true,
		confirmButtonColor: '#3085d6',
		cancelButtonColor:  '#f1f3f3',
		confirmButtonText:  'Best&auml;tigen',
		cancelButtonText:   'Abbrechen',
	    }).then((result) => {
		if (result.value) {
		    Swal.fire({
			title: 'Eingegebener Wert:',
			text: result.value,
			icon: 'success'
		    });

			var my_referer = this.referer;
			var my_timeout = this.timeout;

			$.ajax({
				url: '/_ajax/proc_foo.html?input=' + encodeURIComponent(result.value) + '&' + this.queryString,
				type: 'GET',
				dataType: 'html',
				success: function(response) {
					setTimeout(function() {
						document.location = my_referer;
					}, my_timeout);
				},
				error: function(xhr, status, error) {
					console.error(error);
				}
			});
		}
	    });
    }
}

customElements.define('prism-dialog-sr', PrismDialogSR);

/*
	Created: 20Apr2024
*/
