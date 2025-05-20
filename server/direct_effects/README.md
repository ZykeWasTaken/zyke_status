# Direct Effects

A direct effect call allows us easier integration for specific effects without tying it to a status.

For example, previously you had to trigger high.coke until a specific threshold hits for an effect like movementSpeed to be processed, and for each effect we wanted to process, we had to somehow tie it into a status.

However, now we can directly call to add movementSpeed with x value for y duration with our lifetime automatically managed. It ties into our queue system effortlessly and simplifies the process of single effects to be triggered.
