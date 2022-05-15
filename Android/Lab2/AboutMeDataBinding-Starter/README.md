# Homework Questions

### Question 1
Why do you want to minimize explicit and implicit calls to findViewById()?

1. Every time findViewById() is called, it traverses the view hierarchy.
2. findViewById() runs on the main or UI thread.
3. These calls can slow down the user interface.
4. Your app is less likely to crash.

R: 1

### Question 2
How would you describe data binding?

For example, here are some things you could say about data binding:

1. The big idea about data binding is to create an object that connects/maps/binds two pieces of distant information together at compile time, so that you don't have to look for the data at runtime.
2. The object that surfaces these bindings to you is called the binding object.
3. The binding object is created by the compiler.

R: 1

### Question 3
Which of the following is NOT a benefit of data binding?

1. Code is shorter, easier to read, and easier to maintain.
2. Data and views are clearly separated.
3. The Android system only traverses the view hierarchy once to get each view.
4. Calling findViewById() generates a compiler error.
5. Type safety for accessing views.

R: 4

### Question 4
What is the function of the <layout> tag?

1. You wrap it around your root view in the layout.
2. Bindings are created for all the views in a layout.
3. It designates the top-level view in an XML layout that uses data binding.
4. You can use the <data> tag in inside a <layout> to bind a variable to a data class.

R: 3

### Question 5
Which is the correct way to reference bound data in the XML layout?

1. `android:text="@={myDataClass.property}"`
2. `android:text="@={myDataClass}"`
3. `android:text="@={myDataClass.property.toString()}"`
4. `android:text="@={myDataClass.bound_data.property}"`

R: 1
