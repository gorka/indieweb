# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "swiper", to: "https://ga.jspm.io/npm:swiper@11.1.1/swiper.mjs"
pin "swiper/modules", to: "https://ga.jspm.io/npm:swiper@11.1.1/modules/index.mjs"