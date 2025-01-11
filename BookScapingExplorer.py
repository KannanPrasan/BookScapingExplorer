import streamlit as st
import subprocess


st.title("BookScaping Application")


input1 = st.text_input("Enter the text to search:")
input2 = st.text_input("Enter the Number of books to fetch:")

if st.button("Submit"):
    if input1 and input2:

        result = subprocess.run(
            ["python", "BookScapeFetchBooks.py", input1 , input2],
            text=True,
            capture_output=True
        )

        st.text_area("BookScapeFetchBooks.py:", result.stdout)
    else:
        st.warning("Please fill in both text boxes.")
