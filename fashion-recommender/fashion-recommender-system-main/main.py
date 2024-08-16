import streamlit as st
import os
from PIL import Image, ImageDraw
import numpy as np
import pickle
import tensorflow as tf
from tensorflow.keras.preprocessing import image
from tensorflow.keras.layers import GlobalMaxPooling2D
from tensorflow.keras.applications.resnet50 import ResNet50, preprocess_input
from sklearn.neighbors import NearestNeighbors
from numpy.linalg import norm
import streamlit.components.v1 as components
import socket
import requests
from io import BytesIO
import base64
import openai

# Initialize Streamlit app
st.title('Fashion Recommender System and T-shirt Designer')

# Upload the base T-shirt image
uploaded_file = st.file_uploader("Upload a T-shirt image (JPEG or PNG with transparent background)",
                                 type=["jpeg", "jpg", "png"])

# Check if the user has uploaded a file
if uploaded_file is not None:
    # Create a directory to save uploaded files
    os.makedirs("uploads", exist_ok=True)

    # Save the uploaded T-shirt image
    tshirt_path = os.path.join("uploads", uploaded_file.name)
    with open(tshirt_path, "wb") as f:
        f.write(uploaded_file.read())

    # Display the uploaded T-shirt image
    st.image(tshirt_path, caption='Uploaded T-shirt', use_column_width=True)

    # Customization options
    st.sidebar.header('Customization Options')

    # Logo customization
    uploaded_logo = st.sidebar.file_uploader("Upload a Logo (PNG with transparent background)", type=["png"])

    # Logo size customization
    logo_size = st.sidebar.slider("Logo Size", 0.1, 2.0, 1.0, step=0.1)

    # Vertical position customization
    vertical_position = st.sidebar.slider("Vertical Position", 0.0, 1.0, 0.5, step=0.05)

    # Button to apply customization
    if st.sidebar.button('Apply Customization'):
        # Create a copy of the original T-shirt image
        customized_tshirt = Image.open(tshirt_path).convert("RGBA")

        # Apply logo customization
        if uploaded_logo is not None:
            logo = Image.open(uploaded_logo).convert("RGBA")
        else:
            logo = None

        width, height = customized_tshirt.size

        # Resize the logo based on user input
        if logo is not None:
            logo_width, logo_height = logo.size
            logo_width = int(logo_width * logo_size)
            logo_height = int(logo_height * logo_size)
            logo = logo.resize((logo_width, logo_height))

            # Calculate vertical position
            y_offset = int((height - logo_height) * vertical_position)

            # Paste the logo onto the T-shirt with the calculated position
            x_offset = (width - logo_width) // 2  # Centered horizontally
            customized_tshirt.paste(logo, (x_offset, y_offset), logo)

        # Display the customized T-shirt
        st.image(customized_tshirt, caption='Customized T-shirt', use_column_width=True, channels='RGBA')

# Function to generate clothes using OpenAI DALL-E API
def generate_clothes(prompt, image_size):
    api_key = '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'
    openai.api_key = api_key

    # Create an image using the OpenAI DALL-E API
    response = openai.Image.create(
        prompt=prompt,
        n=1,
        size=f"{image_size}x{image_size}"
    )

    # Extract the image URL from the API response
    image_url = response['data'][0]['url']

    # Download and return the generated image
    image_response = requests.get(image_url)
    if image_response.status_code == 200:
        image_data = Image.open(BytesIO(image_response.content))
        return image_data
    else:
        return None

# User interaction for generating clothes
st.sidebar.header("Generate Your Clothes")
prompt = st.sidebar.text_input('Enter a prompt for generating clothes:')
image_size = st.sidebar.selectbox("Image Size (pixels)", [1024, 512, 256])

if st.sidebar.button("Generate Clothes"):
    if prompt and image_size:
        # Generate and display the clothes image
        generated_image = generate_clothes(prompt, image_size)

        if generated_image:
            st.image(generated_image, caption='Generated Clothes', use_column_width=True)
        else:
            st.error("Failed to generate clothes image. Please check your input or try again later.")
# ... (Previous code)

# Recommendation section
# Load precomputed features and filenames
feature_list = np.array(pickle.load(open('embeddings.pkl', 'rb')))
filenames = pickle.load(open('filenames.pkl', 'rb'))

# Load the ResNet model for feature extraction
model = ResNet50(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
model.trainable = False

model = tf.keras.Sequential([
    model,
    GlobalMaxPooling2D()
])

# Function to save uploaded file
def save_uploaded_file(uploaded_file):
    try:
        with open(os.path.join('uploads', uploaded_file.name), 'wb') as f:
            f.write(uploaded_file.getbuffer())
        return 1
    except:
        return 0

# Function for feature extraction
def feature_extraction(img_path, model):
    img = image.load_img(img_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    expanded_img_array = np.expand_dims(img_array, axis=0)
    preprocessed_img = preprocess_input(expanded_img_array)
    result = model.predict(preprocessed_img).flatten()
    normalized_result = result / norm(result)
    return normalized_result

# Function for recommendation
def recommend(features, feature_list, n_neighbors=50):
    neighbors = NearestNeighbors(n_neighbors=n_neighbors, algorithm='brute', metric='euclidean')
    neighbors.fit(feature_list)
    distances, indices = neighbors.kneighbors([features])
    return indices

# User interaction for recommendations
uploaded_image = st.file_uploader("Choose an image")
num_recommendations = st.number_input("Number of Recommendations (1-50)", min_value=1, max_value=50, value=5)

if uploaded_image is not None:
    if save_uploaded_file(uploaded_image):
        # Display the uploaded image
        display_image = Image.open(uploaded_image)
        st.image(display_image)

        # Extract features from the uploaded image
        features = feature_extraction(os.path.join("uploads", uploaded_image.name), model)

        # Recommend similar images
        indices = recommend(features, feature_list, n_neighbors=num_recommendations)

        # Display recommended images row-wise with increased size
        st.header("Recommended Outfits")
        for i in range(num_recommendations):
            recommended_image_path = filenames[indices[0][i]]
            recommended_image = Image.open(recommended_image_path)
            st.image(recommended_image, width=500, caption=f"Recommendation {i + 1}")
    else:
        st.header("Some error occurred in file upload")
