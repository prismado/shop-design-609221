class PrismCookieConsent extends HTMLElement {
	constructor() {
		super()
		this.lang     = this.getAttribute('lang')
		this.debug    = this.getAttribute('debug')
		this.theme    = this.getAttribute('theme')

		this.innerHTML = `
			<style>
				.footer-hinweis {
					position: fixed;
					bottom: 0; left: 0; width: 100%;
					background-color: #f2f2f2;
					color: black;
					text-align: center;
					padding: 10px 0;
				}
				@keyframes fadeIn {
					from { opacity: 0; }
					to   { opacity: 1; }
				}
			</style>

			<div id="div404152_9"></div>`
	}

	connectedCallback() {
		setTimeout(function(){
			$('#div404152_9').load('/_ajax/webc_prism_cookie_consent.html?msg=tbd+xyz+aei&lang=' + this.lang
				+ '&debug=' + this.debug)
		}.bind(this), 1000);
	}
}

customElements.define('prism-cookie-consent', PrismCookieConsent)

// Created: 15Apr2024
