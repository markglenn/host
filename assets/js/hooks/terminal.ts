import { Terminal } from '@xterm/xterm';
import { FitAddon } from "@xterm/addon-fit";
import { Hook, makeHook } from 'phoenix_typed_hook';

class TerminalHook extends Hook {
  terminal?: Terminal;

  mounted() {
    this.terminal = new Terminal({
      convertEol: true
    });

    const fitAddon = new FitAddon();

    this.terminal.loadAddon(fitAddon);
    this.terminal.open(this.el);

    fitAddon.fit();
    this.handleEvent('terminal-write', ({ content }) => this.handleWrite(content));
  }

  handleWrite(text) {
    this.terminal?.write(text);
  }

  destroyed() {
    this.terminal?.dispose();
  }
}

export default makeHook(TerminalHook);