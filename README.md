# Photon

Photon is a language inspired by typescript that compiles to .NET CLR. It can import and use any .NET libraries.
Projects written in Photon can live alongside projects written in other CLR languages such as C#.

Photon is a hobby project that may never go anywhere. Use at own risk.

Photon Design goals:

-   Be easy to understand and use for typescript developers
-   Be interoperable with C# and other .Net languages
-   Not support some of the more dangerous features of typescript/javascript such as monkey patching or runtime class prototype manipulations
-   Support as many productivity features of typescripts as possible such as type unions and advanced type inferences
-   Add non typescript features that boost developer experience such as pattern matching, pipelining

Current Status: Functional but very unstable and incomplete

How to use:

- Currently only tested on Linux systems. Can be executed on windows but likely won't work. Windows support coming at a later date
- Install .Net 7.0 on your computer
- Install dotnet cmd tool
- Download the compiler from the releases
- Clone the repo and run the photon compiler without arguments in any folder that has a project.json to build it.
- May require to checkout an older commit to build the new version of the compiler first as this project is still in a very unstable state and I'm not releasing a new version for every commit

TODO:

High Priority:
Adapt lexer to support template strings with interpolations
Type inference for array literals
Add Tuples
Implement language server & validation

Normal Priority:
Add compile errors with good UX
Add interfaces
Add mixins
Add decorators (Javascript style decorators that allow to modify the method/class/property it is attached to)
Add JSX (XML literal) support
Improve the way the lexer handles escape sequences
Add Regex Literal

Low Priority:
Windows support

