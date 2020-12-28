
## TouchBar autocomplete in zsh!

![Showcase](https://d.pr/i/1jAY2W+)

Wow, right?

**NOTE:** *You may be asking looking at last commit date, is this even maintained? Yes. It just works so good that I haven't changed a single line of code since that time, even though there've been many releases of iTerm (3.4.3 as of this writing), and the latest macOS is now 11.1. Still works. I still use it ☺️*

### What people say

> Omg
>
> It’s sooooooo goooooooood
>
> — Artyom, CTO of Brolly

### Requirements

* iTerm2 3.1 or higher - [Download](https://www.iterm2.com/downloads.html)
* [zsh](http://www.zsh.org/) shell

**In iterm2:** Go into `View -> Customize Tool Bar...` and drag & drop the `Fn` module

### Installing plugin

Add `source path-to-zsh-touch-complete/boot.sh` to your `.zshrc`.

### Customize

Most customizations are available in `touchbar_style.sh`.

### Read more / Credits

* [Original iTerm2 issue for TouchBar support](https://gitlab.com/gnachman/iterm2/issues/5281)
* [iam4x/zsh-iterm-touchbar](https://github.com/iam4x/zsh-iterm-touchbar) — iTerm touchbar helpers and status line
* [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) — Asynchronous fetching of suggestions
