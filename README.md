# dotfiles

## migrate config

```bash
sh install.sh
```

## install packages

### npm

```bash
xargs npm install -g < .node-global-packages.txt
```

### Homebrew

```bash
brew bundle --global
```

### Claude Code plugins

```bash
claude plugins install evolutionary-naming@kawasima-skills
claude plugins install ponytail@ponytail
```

