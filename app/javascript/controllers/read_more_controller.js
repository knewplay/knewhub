import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() {
    return ["content", "moreButton", "lessButton"]
  }

  static get classes() {
    return ["truncate"]
  }

  static get values() {
    return { lines: Number }
  }

  connect() {
    this.render()
  }

  render() {
    this.showAllContent()

    if (this.height() > this.expectedHeight()) {
      this.showLess()
    } else {
      this.showAllContent()
      this.hide(this.moreButtonTarget);
      this.hide(this.lessButtonTarget);
    }
  }

  showMore() {
    this.showAllContent();
    this.hide(this.moreButtonTarget);
    this.show(this.lessButtonTarget);
  }

  showLess() {
    this.truncateContent();
    this.hide(this.lessButtonTarget);
    this.show(this.moreButtonTarget);
  }

  showAllContent() {
    this.contentTarget.classList.remove(this.truncateClass);
  }

  truncateContent() {
    this.contentTarget.style["-webkit-line-clamp"] = this.linesValue;
    this.contentTarget.classList.add(this.truncateClass);
  }

  show(target) {
    target.classList.remove('hide')
  }

  hide(target) {
    target.classList.add('hide')
  }

  lineHeight() {
    let style = window.getComputedStyle(this.contentTarget)
    return parseFloat(style.lineHeight, 10);
  }

  height() {
    return this.contentTarget.offsetHeight;
  }

  expectedHeight() {
    return this.linesValue * this.lineHeight();
  }
}
