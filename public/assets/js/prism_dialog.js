class PrismDialog extends HTMLElement {
	constructor() {
		super()
		this.prompt      = this.getAttribute('prompt')
		this.callback    = this.getAttribute('callback')
		this.instruction = this.getAttribute('instruction')
		this.lang        = this.getAttribute('lang')
		this.timeout     = this.getAttribute('timeout')
		this.css_id      = this.getAttribute('css_id') || 'div404181_24'
		this.debug       = this.getAttribute('debug')
		// this.theme    = this.getAttribute('theme')

		let queryStringParts = [];

		Array.from(this.attributes).forEach(attr => {
			if (attr.name.startsWith('x_')) {
				let encodedValue = encodeURIComponent(attr.value);
				queryStringParts.push(`${attr.name}=${encodedValue}`);
			}
		});

		this.queryString = queryStringParts.join('&');

		this.innerHTML = `
			<button class="btn btn-primary btn-sm btn-soft p-2 pt--0 pl--4 pr--4 pb--0"
				onclick="zeigenZahlEingabe`+ this.css_id + `()">` + this.prompt + `</button>

			<div id="` + this.css_id + `"></div>`
	}

	connectedCallback() {
		$('#' + this.css_id).load('/_ajax/webc_prism_dialog.html?prompt=' + encodeURIComponent(this.prompt) + '&lang=' + this.lang
			+ '&' + this.queryString + '&timeout=' + this.timeout + '&css_id=' + this.css_id
			+ '&callback=' + this.callback + '&instruction=' + encodeURIComponent(this.instruction) + '&debug=' + this.debug);
	}
}

customElements.define('prism-dialog', PrismDialog)

// Created: 18Apr2024
