# Antz : A simulation of ants behaviour in Processing

The goal of "Antz" is to show that from a very simple set of rules, repeated by many
agents (here virtual ants!), a complex task can be executed.

For "Antz" the basic rules are:

when not carrying food:
- search randomly (e.g. Gaussian randomness) ; they start from the nest.
- if some food is found then pick it up
 -else if a 'strong enough' pheromone trail is found then try to follow it

when carrying food:
- go back to the nest in the shortest possible way
- leave a pheromone trail behind
- if the nest is reached, put the food down.

The pheromone trail fades away as the time goes by. I would make the trail not a single
pixel wide line, but instead a few pixels wide with a gradient from the ant actual path.
The pheromones from several ants accumulate.
A food source disappears when empty (several sources are generated when starting).

Furthermore some obstacles are added to show that the ants "choose" the shortest way
around an obstacle, due to the fact that the short path has a more dense pheromone
trail than the longest which eventually gets discarded. (This principle is studied
in the data routing/networking field).

To be honest it's not quite there yet to show that last point in the current version.
