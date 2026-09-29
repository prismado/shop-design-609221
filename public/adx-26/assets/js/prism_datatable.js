class PrismDataTables extends HTMLElement {
	constructor() {
		super()
		this.role     = this.getAttribute('role')
		this.dt_ver   = this.getAttribute('dt_ver')
		this.debug    = this.getAttribute('debug')
		this.table    = this.getAttribute('table')
		this.macro    = this.getAttribute('macro')
		this.fil      = this.getAttribute('fil')
		this.q        = this.getAttribute('q') || ''
		this.omit     = this.getAttribute('omit')
		this.theme    = this.getAttribute('theme')

		this.innerHTML = `<div id="div10_402071_` + this.table + `"></div>`
	}

	connectedCallback() {
		$('#div10_402071_' + this.table).load('_ajax/webc_prism_datatable.html?msg=tbd+402071&table=' + this.table
			+ '&macro=' + this.macro + '&fil=' + this.fil + '&q=' + this.q + '&omit=' + this.omit + '&theme=' + this.theme + '&debug=' + this.debug)
	}
}

customElements.define('prism-datatable', PrismDataTables)

// Created: 07Feb2024
