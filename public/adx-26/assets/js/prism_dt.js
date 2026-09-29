class PrismDataTables extends HTMLElement {
	constructor() {
		super()
		this.role    = this.getAttribute('role')
		this.dt_ver  = this.getAttribute('dt_ver')
		this.debug   = this.getAttribute('debug')
		this.table   = this.getAttribute('table')
		this.show_all = this.getAttribute('show_all')

		this.innerHTML = `<div id="div8_312191_` + this.table + `"></div>`
	}

	connectedCallback() {
		/*
		this.querySelector('button').addEventListener('click', (event) => {
			alert(this.getAttribute('alert'))
		})
		*/

		if (this.table == 'categories') {
			this.lang    = this.getAttribute('lang')    || 'de'
			this.visible = this.getAttribute('visible') || 1
			$('#div8_312191_' + this.table).load('_ajax/webc_datatables_categories.html?dt_ver=1.9.1&lang='
					+ this.lang + '&table=' + this.table + '&visible=' + this.visible)
		}
		else {
			$('#div8_312191_' + this.table).load('_ajax/webc_datatables.html?msg=Default+WebC&table=' + this.table
				+ '&show_all=' + this.show_all + '&debug=' + this.debug)
		}
	}
}

customElements.define('prism-datatable', PrismDataTables)

// Created: 19Dec2023
