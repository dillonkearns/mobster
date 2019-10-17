module Tip.PragmaticProgrammer exposing (tips)

import Tip exposing (Tip)


tips : List Tip
tips =
    [ { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Care About Your Craft"
      , body = "Why spend your life developing software unless you care about doing it well?"
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Provide Options, Don’t Make Lame Excuses"
      , body = "Instead of excuses, provide options. Don’t say it can’t be done; explain what can be done.."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Be a Catalyst for Change"
      , body = "You can’t force change on people. Instead, show them how the future might be and help them participate in creating it."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Make Quality a Requirements Issue"
      , body = "Involve your users in determining the project’s real quality requirements."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Critically Analyze What You Read and Hear"
      , body = "Don’t be swayed by vendors, media hype, or dogma. Analyze information in terms of you and your project."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "DRY—Don’t Repeat Yourself"
      , body = "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Eliminate Effects Between Unrelated Things"
      , body = "Design components that are self-contained, independent, and have a single, well-defined purpose."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Use Tracer Bullets to Find the Target"
      , body = "Tracer bullets let you home in on your target by trying things and seeing how close they land."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Program Close to the Problem Domain"
      , body = "Design and code in your user’s language."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Iterate the Schedule with the Code"
      , body = "Use experience you gain as you implement to refine the project time scales."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Use the Power of Command Shells"
      , body = "Use the shell when graphical user interfaces don’t cut it."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Always Use Source Code Control"
      , body = "Source code control is a time machine for your work—you can go back."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Don’t Panic When Debugging"
      , body = "Take a deep breath and THINK! about what could be causing the bug."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Don’t Assume It—Prove It"
      , body = "Prove your assumptions in the actual environment—with real data and boundary conditions."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Write Code That Writes Code"
      , body = "Code generators increase your productivity and help avoid duplication."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Design with Contracts"
      , body = "Use contracts to document and verify that code does no more and no less than it claims to do."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Use Assertions to Prevent the Impossible"
      , body = "Assertions validate your assumptions. Use them to protect your code from an uncertain world."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Finish What You Start"
      , body = "Where possible, the routine or object that allocates a resource should be responsible for deallocating it."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Configure, Don’t Integrate"
      , body = "Implement technology choices for an application as configuration options, not through integration or engineering."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Analyze Workflow to Improve Concurrency"
      , body = "Exploit concurrency in your user’s workflow."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Always Design for Concurrency"
      , body = "Allow for concurrency, and you’ll design cleaner interfaces with fewer assumptions."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Use Blackboards to Coordinate Workflow"
      , body = "Use blackboards to coordinate disparate facts and agents, while maintaining independence and isolation among participants."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Estimate the Order of Your Algorithms"
      , body = "Get a feel for how long things are likely to take before you write code."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Refactor Early, Refactor Often"
      , body = "Just as you might weed and rearrange a garden, rewrite, rework, and re-architect code when it needs it. Fix the root of the problem."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Test Your Software, or Your Users Will"
      , body = "Test ruthlessly. Don’t make your users find bugs for you."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Don’t Gather Requirements—Dig for Them"
      , body = "Requirements rarely lie on the surface. They’re buried deep beneath layers of assumptions, misconceptions, and politics."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Abstractions Live Longer than Details"
      , body = "Invest in the abstraction, not the implementation. Abstractions can survive the barrage of changes from different implementations and new technologies."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Don’t Think Outside the Box—Find the Box"
      , body = "When faced with an impossible problem, identify the real constraints. Ask yourself: “Does it have to be done this way? Does it have to be done at all?”"
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Some Things Are Better Done than Described"
      , body = "Don’t fall into the specification spiral—at some point you need to start coding."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Costly Tools Don’t Produce Better Designs"
      , body = "Beware of vendor hype, industry dogma, and the aura of the price tag. Judge tools on their merits."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Don’t Use Manual Procedures"
      , body = "A shell script or batch file will execute the same instructions, in the same order, time after time."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Coding Ain’t Done ‘Til All the Tests Run"
      , body = "‘Nuff said."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Test State Coverage, Not Code Coverage"
      , body = "Identify and test significant program states. Just testing lines of code isn’t enough."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "English is Just a Programming Language"
      , body = "Write documents as you would write code: honor the DRY principle, use metadata, MVC, automatic generation, and so on."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Gently Exceed Your Users’ Expectations"
      , body = "Come to understand your users’ expectations, then deliver just that little bit more."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Think! About Your Work"
      , body = "Turn off the autopilot and take control. Constantly critique and appraise your work."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Don’t Live with Broken Windows"
      , body = "Fix bad designs, wrong decisions, and poor code when you see them."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Remember the Big Picture"
      , body = "Don’t get so engrossed in the details that you forget to check what’s happening around you."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Invest Regularly in Your Knowledge Portfolio"
      , body = "Make learning a habit."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "It’s Both What You Say and the Way You Say It"
      , body = "There’s no point in having great ideas if you don’t communicate them effectively."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Make It Easy to Reuse"
      , body = "If it’s easy to reuse, people will. Create an environment that supports reuse."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "There Are No Final Decisions"
      , body = "No decision is cast in stone. Instead, consider each as being written in the sand at the beach, and plan for change."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Prototype to Learn"
      , body = "Prototyping is a learning experience. Its value lies not in the code you produce, but in the lessons you learn."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Estimate to Avoid Surprises"
      , body = "Estimate before you start. You’ll spot potential problems up front."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Keep Knowledge in Plain Text"
      , body = "Plain text won’t become obsolete. It helps leverage your work and simplifies debugging and testing."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Use a Single Editor Well"
      , body = "The editor should be an extension of your hand; make sure your editor is configurable, extensible, and programmable."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Fix the Problem, Not the Blame"
      , body = "It doesn’t really matter whether the bug is your fault or someone else’s—it is still your problem, and it still needs to be fixed."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "“select” Isn’t Broken"
      , body = "It is rare to find a bug in the OS or the compiler, or even a third-party product or library. The bug is most likely in the application."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Learn a Text Manipulation Language"
      , body = "You spend a large part of each day working with text. Why not have the computer do some of it for you?"
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "You Can’t Write Perfect Software"
      , body = "Software can’t be perfect. Protect your code and users from the inevitable errors."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Crash Early"
      , body = "A dead program normally does a lot less damage than a crippled one."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Use Exceptions for Exceptional Problems"
      , body = "Exceptions can suffer from all the readability and maintainability problems of classic spaghetti code. Reserve exceptions for exceptional things."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Minimize Coupling Between Modules"
      , body = "Avoid coupling by writing “shy” code and applying the Law of Demeter."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Put Abstractions in Code, Details in Metadata"
      , body = "Program for the general case, and put the specifics outside the compiled code base."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Design Using Services"
      , body = "Design in terms of services—independent, concurrent objects behind well-defined, consistent interfaces."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Separate Views from Models"
      , body = "Gain flexibility at low cost by designing your application in terms of models and views."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Don’t Program by Coincidence"
      , body = "Rely only on reliable things. Beware of accidental complexity, and don’t confuse a happy coincidence with a purposeful plan."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Test Your Estimates"
      , body = "Mathematical analysis of algorithms doesn’t tell you everything. Try timing your code in its target environment."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Design to Test"
      , body = "Start thinking about testing before you write a line of code."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Don’t Use Wizard Code You Don’t Understand"
      , body = "Wizards can generate reams of code. Make sure you understand all of it before you incorporate it into your project."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Work with a User to Think Like a User"
      , body = "It’s the best way to gain insight into how the system will really be used."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Use a Project Glossary"
      , body = "Create and maintain a single source of all the specific terms and vocabulary for a project."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Start When You’re Ready"
      , body = "You’ve been building experience all your life. Don’t ignore niggling doubts."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Don’t Be a Slave to Formal Methods"
      , body = "Don’t blindly adopt any technique without putting it into the context of your development practices and capabilities."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Organize Teams Around Functionality"
      , body = "Don’t separate designers from coders, testers from data modelers. Build teams the way you build code."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Test Early. Test Often. Test Automatically."
      , body = "Tests that run with every build are much more effective than test plans that sit on a shelf."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Use Saboteurs to Test Your Testing"
      , body = "Introduce bugs on purpose in a separate copy of the source to verify that testing will catch them."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Find Bugs Once"
      , body = "Once a human tester finds a bug, it should be the last time a human tester finds that bug. Automatic tests should check for it from then on."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Build Documentation In, Don’t Bolt It On"
      , body = "Documentation created separately from code is less likely to be correct and up to date."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    , { url = "https://pragprog.com/the-pragmatic-programmer/extracts/tips"
      , title = "Sign Your Work"
      , body = "Craftsmen of an earlier age were proud to sign their work. You should be, too."
      , author = "The Pragmatic Programmer by Andy Hunt & Dave Thomas"
      }
    ]
