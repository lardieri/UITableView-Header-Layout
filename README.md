#  UITableView Header Layout

_Explore UITableView's logic for sizing and positioning its tableHeaderView._

Sizing a table header view correctly presents a challenge for many iOS developers, especially when creating and adding the header view in code instead of using a Storyboard.

The difficulty originates from the fact that UITableView does not use either traditional resizing masks or Auto Layout to position and resize its header view. It has its own way of doing things that you need to understand.

This project shows how to create, size, and add a custom table header view in code. There are flags for using resizing masks or Auto Layout, and for using fixed child elements versus child elements in a UIStackView.

It also shows how to dynamically resize the tableHeaderView. Tapping on the header randomly changes its size and updates the UITableView with the resized header. 

## Rules for sizing UITableView table header views

The order of the following operations is important!   

1. Create the header view. But don't add it to the UITableView yet.

2. Set the header's frame with the correct height.

   -- If you **are** using Auto Layout, create a height constraint and force Auto Layout to calculate the frame. If your header's height is determined by its children, make sure those constraints are set up by now.
   
   -- If you're **not** using Auto Layout, fill in the frame yourself. Only the height must be correct. Don't worry about the other elements, they will get overwritten.

3. Set the UITableView's `.tableHeaderView` property to your header view.

   The property setter is magic; it does three things:
   
    A) The table view adds the header as a subview.
    
    B) The table view looks at the header's `.frame.height` property and adjusts the cells down to make room. The table view only looks at the header's height in this one place, and never looks at it again.
    
    C) The table view adjusts the *origin* and *width* of the header's frame to position it at the top of the table view and stretch it across the entire width. The table view continues to adjust the origin and width of the header's frame whenever its own bounds get updated. Your autoresizeMask gets ignored.

4. If you **are** using Auto Layout, create constraints between the header and the table view for position and width. Auto Layout assumes it owns the header's entire frame (all 4 elements), so it overwrites the values for *origin* and *width* that the UITableView puts into the header view's frame. You need to add constraints that duplicate what the UITableView is doing. But you can't activate these constraints until the header is part of the table view's hierarchy or you will crash.

5. When the size of the header view changes:

    A) Calculate the new height of the header view.
    
    B) Update the header view's `.frame` property, changing only the height.
    
    C) Set the header view as the UITableView's `.tableHeaderView` property again, even though it's the same view. 
