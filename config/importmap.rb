# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@github/webauthn-json", to: "https://ga.jspm.io/npm:@github/webauthn-json@2.1.1/dist/esm/webauthn-json.js"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.8/src/index.js"
pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@7.0.6/lib/assets/compiled/rails-ujs.js"
pin "@fortawesome/fontawesome-free", to: "https://ga.jspm.io/npm:@fortawesome/fontawesome-free@6.4.2/js/fontawesome.js"
pin "@fortawesome/fontawesome-svg-core", to: "https://ga.jspm.io/npm:@fortawesome/fontawesome-svg-core@6.4.2/index.mjs"
pin "@fortawesome/free-brands-svg-icons", to: "https://ga.jspm.io/npm:@fortawesome/free-brands-svg-icons@6.4.2/index.mjs"
pin "@fortawesome/free-regular-svg-icons", to: "https://ga.jspm.io/npm:@fortawesome/free-regular-svg-icons@6.4.2/index.mjs"
pin "@fortawesome/free-solid-svg-icons", to: "https://ga.jspm.io/npm:@fortawesome/free-solid-svg-icons@6.4.2/index.mjs"
pin "timezone"
pin "@marp-team/marpit", to: "https://ga.jspm.io/npm:@marp-team/marpit@2.6.1/lib/index.js"
pin "buffer", to: "https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/buffer.js"
pin "color-name", to: "https://ga.jspm.io/npm:color-name@1.1.4/index.js"
pin "color-string", to: "https://ga.jspm.io/npm:color-string@1.9.1/index.js"
pin "cssesc", to: "https://ga.jspm.io/npm:cssesc@3.0.0/cssesc.js"
pin "entities/lib/maps/entities.json", to: "https://ga.jspm.io/npm:entities@3.0.1/lib/maps/entities.json.js"
pin "fs", to: "https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/fs.js"
pin "is-arrayish", to: "https://ga.jspm.io/npm:is-arrayish@0.3.2/index.js"
pin "js-yaml", to: "https://ga.jspm.io/npm:js-yaml@4.1.0/index.js"
pin "linkify-it", to: "https://ga.jspm.io/npm:linkify-it@4.0.1/index.js"
pin "lodash.kebabcase", to: "https://ga.jspm.io/npm:lodash.kebabcase@4.1.1/index.js"
pin "markdown-it", to: "https://ga.jspm.io/npm:markdown-it@13.0.2/index.js"
pin "markdown-it-front-matter", to: "https://ga.jspm.io/npm:markdown-it-front-matter@0.2.3/index.js"
pin "mdurl", to: "https://ga.jspm.io/npm:mdurl@1.0.1/index.js"
pin "nanoid/non-secure", to: "https://ga.jspm.io/npm:nanoid@3.3.7/non-secure/index.cjs"
pin "path", to: "https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/path.js"
pin "picocolors", to: "https://ga.jspm.io/npm:picocolors@1.0.0/picocolors.browser.js"
pin "postcss", to: "https://ga.jspm.io/npm:postcss@8.4.32/lib/postcss.js"
pin "process", to: "https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/process-production.js"
pin "punycode", to: "https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/punycode.js"
pin "simple-swizzle", to: "https://ga.jspm.io/npm:simple-swizzle@0.2.2/index.js"
pin "source-map-js", to: "https://ga.jspm.io/npm:source-map-js@1.0.2/source-map.js"
pin "uc.micro", to: "https://ga.jspm.io/npm:uc.micro@1.0.6/index.js"
pin "uc.micro/categories/Cc/regex", to: "https://ga.jspm.io/npm:uc.micro@1.0.6/categories/Cc/regex.js"
pin "uc.micro/categories/P/regex", to: "https://ga.jspm.io/npm:uc.micro@1.0.6/categories/P/regex.js"
pin "uc.micro/categories/Z/regex", to: "https://ga.jspm.io/npm:uc.micro@1.0.6/categories/Z/regex.js"
pin "uc.micro/properties/Any/regex", to: "https://ga.jspm.io/npm:uc.micro@1.0.6/properties/Any/regex.js"
pin "url", to: "https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/url.js"
pin "swiper/element/bundle", to: "https://ga.jspm.io/npm:swiper@11.0.5/swiper-element-bundle.mjs"
pin "three" # @0.162.0
