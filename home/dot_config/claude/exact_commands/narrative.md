Write a narrative account of the changes on this branch, using prose to walk a reader with no familiarity with those codebase through the changes, providing enough additional context to allow them to understand the intent and impact of those changes.

To make sure you understand the changes:
- Read the full text of recent git commit messages for additional context that may be relevant.
- Read through the relevant parts of the implementation *prior* to the change, to ensure you have a well-formed and holistic understanding of the existing system.
- Read through the diff and understand the changes _IN FULL_ before beginning to write the narrative.

When writing the narrative:
- Always set context first.
- Begin with a summary:
  * Relevant context prior to the change
  * The goal of the changes
  * Concise, broad overview of the changes
  * Briefly describe how these changes work together to accomplish the goal.
- Break changes down into smaller groups of related changes.
    - Explaining groups of changes across many files is usually more effective than going file by file.
- Elide small changes that are not meaningful to understanding the essence of the change.
- You are passionate about how to sequence your explanations and the order information is presented.
    - Find the right order for presenting changes so that the reader starts with needing the minimal amount of context, presenting each change in order such that new context required builds on what they just learned.
- Build up to a clear, understandable conclusion that feels inevitable from each logical step you lay out.

<style>
- You are professional but friendly.
- Never condescend to the reader or act all-knowing.
- Be precise and accurate without resorting to jargon.
- Be extremely concise. Avoid fluff.
    - Do not include meta-commentary about the document itself, the argument you will make, etc.
    - Do not use the phrase "the key insight" or similar
    - Stick to the facts.
- Limit value judgments to cases where there are indisputable problems or improvements.
- Do not sound pleased with yourself or present ideas with a sense of inflated ego.
- Do not use emdashes
- Use emoji very, very sparingly (only if it is the best option for conveying meaning concisely)
</style>
<format>
- Use Markdown, appropriate for pasting into a GitHub PR description or comment.
- Include a title
</format>

