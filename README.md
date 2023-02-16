# Photon

Photon is a language inspired by typescript that compiles to .NET CLR. It can import and use any .NET libraries.
Projects written in Photon can live alongside projects written in other CLR languages such as C#.

Photon is a hobby project that may never go anywhere. Use at own risk.

Photon Design goals:

-   Be easy to understand and use for typescript developers
-   Be interoperable with C# and other .Net languages
-   Not support some of the more dangerous features of typescript/javascript such as monkey patching or runtime class prototype manipulations
-   Be as similar to typescript as possible while diverging from typescript only for technical limitations of improvements to code readability or productivity reasons (e.g. pattern matching)
-   Add non typescript features that boost developer experience such as pattern matching, pipelining

Current Status: Functional but very unstable and incomplete

How to use:

- Currently only tested on Linux systems. Can be executed on windows but likely won't work. Windows support coming at a later date
- Install .Net 7.0 on your computer
- Install dotnet cmd tool
- Clone the repo
- Run ./install.sh
- use `ph` cli tool for building projects. Run it without argument in a folder with a photon.json to build

TODO:

High Priority:
- Adapt lexer to support template strings with interpolations
- Type inference for array literals
- Implement language server & validation
- Implement IL emit
- Implement photon debugging (currently you can only debug the intermediary code)

Normal Priority:
- Add Tuples
- Pattern matching without return values, with statements instead of expressions, with non constant patterns
- Add compile errors with good UX
- Add interfaces
- Add mixins
- Add decorators (Javascript style decorators that allow to modify the method/class/property it is attached to)
- Add JSX (XML literal) support
- Improve the way the lexer handles escape sequences
- Add Regex Literal
- Pipeline and async pipeline operator support
- "const" argument modifier
- Operator overloading
- Async constructor
- Add missing struct features
- Macro Support

Low Priority:
- Windows support
- Blazor Support
