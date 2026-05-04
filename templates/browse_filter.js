(() => {
  'use strict'

  function initBrowseFilter() {
    const controls = document.querySelector('.browse-filter')
    if (!controls) return

    const items = document.querySelectorAll('li[data-public]')
    if (!items.length) return

    controls.addEventListener('change', e => {
      if (e.target.name !== 'visibility-filter') return
      const value = e.target.value
      const url = new URL(location.href)
      if (value === 'all') {
        url.searchParams.delete('filter')
      } else {
        url.searchParams.set('filter', value)
      }
      history.replaceState(null, '', url)
      applyFilter(value)
    })

    // Apply filter from URL on page load
    const initialFilter = new URL(location.href).searchParams.get('filter') || 'all'
    if (initialFilter !== 'all') {
      const radio = controls.querySelector(`input[value="${initialFilter}"]`)
      if (radio) radio.checked = true
      applyFilter(initialFilter)
    }

    function applyFilter(value) {
      items.forEach(li => {
        const isPublic = li.dataset.public === 'true'
        const show = value === 'all' || (value === 'public' && isPublic)
        li.hidden = !show
      })

      // Hide empty subject <details> sections and update their counts
      document.querySelectorAll('details[id^="subject-"]').forEach(details => {
        const visibleItems = details.querySelectorAll('li[data-public]:not([hidden])')
        details.hidden = visibleItems.length === 0
        const countEl = details.querySelector('.subject-count')
        if (countEl) {
          countEl.textContent = `(${visibleItems.length})`
        }
      })

      // Hide empty letter sections on the title browse page
      document.querySelectorAll('.letter-section').forEach(section => {
        section.hidden = section.querySelectorAll('li[data-public]:not([hidden])').length === 0
      })

      // Dim alpha-nav links whose letter section is now hidden
      document.querySelectorAll('.alpha-nav a').forEach(link => {
        const href = link.getAttribute('href')
        if (!href) return
        const target = document.querySelector(href)
        if (target) {
          link.classList.toggle('alpha-nav__inactive', target.hidden)
        }
      })

      // Update the total count shown in the browse header
      const countEl = document.querySelector('.browse-visible-count')
      if (countEl) {
        countEl.textContent = document.querySelectorAll('li[data-public]:not([hidden])').length
      }
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initBrowseFilter)
  } else {
    initBrowseFilter()
  }
})()
