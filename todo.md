Work for swarm:
---------------

*   Make 3d: The same algorithm applies, but the code will have to be refigured to allow for 3d rendering and include 3d vectors instead of 2d. This should be done on a separate branch, so we can always go back to 2d if we like.

*   Optimize with a location grid: currently, each boid checks its distance from every other boid at each time step. This makes for O(n^2) runtime, which is not fast enough for the swarm. If the world is divided into a grid where each square has side-lengths equal to the largest awareness-radius of each boid (currently, alignR and separateR are tied for this) then each boid need only compare itself to the boids in the Moore neighborhood around it. If we assume that the swarm always reaches a terminal density, then this technique would reduce the runtime from O(n^2) to O(n). Wow-wee!!!!!!!!!

*   Optimize by halving the number of position comparisons: currently, we make no use of the fact that if b is in a's cohere/separate/align neighborhood, a must be in b's as well. As far as I can tell, the easiest way to do this requires us to add a few swarming-related terms to each boid object, as well as shifting all the boids between two flocks at each update step. It's questionable as to whether this is worth it. Anyway, I imagine we remove boids from the swarm one at a time, checking that boid against those still in the flock. Say we take out boid a: if we find a boid b in the flock that is in a's cohere neighborhood, once we have added the "cohere towards b" impulse to boid a, we simply add its opposite vector to boid b.

*   Parallelize: this isn't absolutely necessary, but would almost certainly allow us to make way more boids, which would look cool. We'd have to figure out if the extra software infrastructure/complexity is worth it.

*   Projection: Ideally, there'd be three or four projectors on the various walls of the room, all stitched together to make one screen. How can we do this? Someone told me there's software out there. Gotta figure it out. How do we send signal from one computer to multiple projectors?
    * Depending on our ambition and projector setup, and if the swarm is 2 or 3d, there might be some interesting virtual world geometries to explore. How could we represent these in the swarm code?

*   Xbox Kinect: We need three things:
    * The Kinect should produce a map of each person's coordinates within the room, to see how close they are to the swarm
    * We have to get that data onto a computer. It's apparently not trivial to connect a Kinect to a mac. Try [this tutorial.](http://www.alan-pipitone.com/index.php/en/blogeng/apple-mac/item/84-use-kinect-with-mac-osx "Alan Pipitone's Kinect Mac tutorial")
    * Once on a computer, the data has to feed into our swarm program as it executes.

*   Execution: we need
    * A powerful computer somewhere on campus which can do all the difficult computation, which can run uninterrupted all weekend.
    * A secure (from revelers) computer in the same room as the swarm where we'll control it, which can run uninterrupted all weekend.
    * A means of connecting the two.
