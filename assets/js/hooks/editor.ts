import loader from '@monaco-editor/loader';

import { Hook, makeHook } from '../../vendor/phoenix_typed_hook';

class EditorHook extends Hook {
  mounted() {
    loader.init().then((monaco) => {
      const readOnly = this.el.dataset.readonly === 'true';
      const theme = this.el.dataset.theme || 'vs-dark';
      const language = this.el.dataset.lang || 'plaintext';

      if (readOnly) {
        monaco.editor.colorizeElement(this.el, {})
      } else {
        const editor = monaco.editor.create(this.el, {
          value: this.el.dataset.value || '',
          language,
          theme,
          minimap: {
            enabled: false
          },
          automaticLayout: true
        });

        editor.onDidChangeModelContent(() => {
          //this.el.value = editor.getValue();
        });
      }
    });
  }
}

export default makeHook(EditorHook);