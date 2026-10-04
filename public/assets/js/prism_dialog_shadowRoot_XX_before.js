class PrismDialogSR extends HTMLElement {
    constructor() {
	super();

	// Erstelle einen Shadow Root
	this.attachShadow({ mode: 'open' });

	// Attribute initialisieren
	this.prompt      = this.getAttribute('prompt');
	this.callback    = this.getAttribute('callback');
	this.instruction = this.getAttribute('instruction');
	this.lang        = this.getAttribute('lang');
	this.timeout     = this.getAttribute('timeout');
	this.css_id      = this.getAttribute('css_id') || 'div404181_24';
	this.debug       = this.getAttribute('debug');

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
	    <button class="btn btn-primary btn-sm btn-soft p-2 pt--0 pl--4 pr--4 pb--0">
		${this.prompt}
	    </button>
	    <div id="${this.css_id}"></div>
	`;

	// Event Listener für den Button hinzufügen
	this.shadowRoot.querySelector('button').addEventListener('click', () => {
	    this.showDialog();
	});
    }

    connectedCallback() {
	this.loadDialog();
    }

    loadDialog() {
	// Implementiere eine Methode, um den Dialoginhalt zu laden

function loadAndExecuteScripts(container, html) {
    container.innerHTML = html;
    const scripts = container.querySelectorAll('script');
    scripts.forEach(script => {
        const newScript = document.createElement('script');
        newScript.text = script.text;
        document.body.appendChild(newScript).parentNode.removeChild(newScript);
    });
}
	fetch('/_ajax/webc_prism_dialog.html?prompt=' + encodeURIComponent(this.prompt) + '&lang=' + this.lang
	    + '&' + this.queryString + '&timeout=' + this.timeout + '&css_id=' + this.css_id
	    + '&callback=' + this.callback + '&instruction=' + encodeURIComponent(this.instruction) + '&debug=' + this.debug)
	    .then(response => response.text())
	    .then(html => {
		// this.shadowRoot.querySelector(`#${this.css_id}`).innerHTML = html;
		loadAndExecuteScripts(this.shadowRoot.querySelector(`#${this.css_id}`), html);
	    });
    }

    showDialog() {
	// Implementiere eine Funktion, die benötigt wird, um den Dialog zu zeigen
	console.log("Dialog anzeigen für: " + this.css_id);
	// Hier müsstest du definieren, was passiert, wenn der Button geklickt wird
	    Swal.fire({
		title: this.prompt,
		input: 'text', // -- number
		inputLabel: 'XX instr',
		inputPlaceholder: 'Zahl hier eingeben',
		inputAttributes: {
		    'aria-label': ''
		},
		// -- 20Apr2024 (optional)
		customClass: {
			confirmButton: 'btn btn-sm w--150 btn-primary',
			cancelButton:  'btn btn-sm w--150 text-dark',
			input: 'mein-custom-input',
			container: 'custom-swal',
			popup: 'custom-popup'
		},
		showCancelButton: true,
		confirmButtonColor: '#3085d6',
		cancelButtonColor:  '#f1f3f3',
		confirmButtonText: 'Best&auml;tigen',
		cancelButtonText: 'Abbrechen',
	    }).then((result) => {
		if (result.value) {
		    Swal.fire({
			title: 'Eingegebene Zahl:',
			text: result.value,
			icon: 'success'
		    });

			$.ajax({
				url: '/_ajax/proc_foo.html?input=' + encodeURIComponent(result.value) + '&extra=9999' + '&' + this.queryString,
				type: 'GET',
				dataType: 'html',
				success: function(response) {
					setTimeout(function() {
						document.location = '/';
					}, 1250);
				},
				error: function(xhr, status, error) {
					console.error(error);
				}
			});
		}
	    });
	// --------------------------------------------------------------------------------------------
    }
}

customElements.define('prism-dialog-sr', PrismDialogSR);

/*
	Created: 20Apr2024
*/
