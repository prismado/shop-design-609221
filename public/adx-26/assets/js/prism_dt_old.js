class PrismDataTables extends HTMLElement {
	constructor() {
		super()
		this.role    = this.getAttribute('role')
		this.dt_ver  = this.getAttribute('dt_ver')
		this.debug   = this.getAttribute('debug')
		this.table   = this.getAttribute('table')

		this.innerHTML = `<div id="div8_312191_` + this.table + `"></div>`
	}

	connectedCallback() {
		/*
		this.querySelector('button').addEventListener('click', (event) => {
			alert(this.getAttribute('alert'))
		})
		*/

		if (this.table == 'vorders') {
			$('#div8_312191_' + this.table).load('_ajax/webc_datatables.html?msg=default&table=' + this.table + '&debug=' + this.debug)
		}
		else if (this.table == 'categories') {
			this.lang    = this.getAttribute('lang')
			this.visible = this.getAttribute('visible')
			$('#div8_312191_' + this.table).load('_ajax/webc_datatables_categories.html?dt_ver=1.9.1&lang='
					+ this.lang + '&table=' + this.table + '&visible=' + this.visible)
		}
		else if (this.table == 'vusers') {
			$('#div8_312191_' + this.table).load('_ajax/webc_datatables.html?x=321&msg=etc&table=' + this.table + '&debug=' + this.debug)
		}
		else {
			$('#div8_312191_' + this.table).load('_ajax/webc_datatables.html?x=4321&msg=etc&table=' + this.table + '&debug=' + this.debug)
		}
	}
}

customElements.define('prism-datatable', PrismDataTables)

// Created: 19Dec2023
