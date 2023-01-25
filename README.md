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

Current Status: Unusable

TODO:

-   Adapt lexer to support template strings with interpolations
-   Improve the way the lexer handles escape sequences
-   Add Regex Literal
-   Implement compiler
-   Implement language server & validation
