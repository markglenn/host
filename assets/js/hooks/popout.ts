import { Hook, makeHook } from 'phoenix_typed_hook';

class PopoutHook extends Hook {
  mounted() {
    this.el.addEventListener('click', (event) => {
      const url = this.el.attributes['href'].value;

      if (this.el.dataset['width']) {
        let width = this.el.dataset.width || '800';
        let height = this.el.dataset.height || '600';

        window.open(url, '_blank', `toolbar=0,location=0,menubar=0,width=${width},height=${height}`);
      } else {
        window.open(url, '_blank', 'toolbar=0,location=0,menubar=0');
      }

      event.preventDefault();
    });
  }
}

export default makeHook(PopoutHook);