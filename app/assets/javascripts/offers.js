function initDropZone()
{
  // Get the template HTML and remove it from the documenthe template HTML and remove it from the document
  var previewNode = document.querySelector("#template");
  previewNode.id = "";
  var previewTemplate = previewNode.parentNode.innerHTML;
  previewNode.parentNode.removeChild(previewNode);

  var myDropzone = new Dropzone(document.body, { // Make the whole body a dropzone
    url: "/offers", // Set the url
    thumbnailWidth: 80,
    thumbnailHeight: 80,
    parallelUploads: 20,
    previewTemplate: previewTemplate,
    autoQueue: false, // Make sure the files aren't queued until manually added
    previewsContainer: "#previews", // Define the container to display the previews
    clickable: ".fileinput-button", // Define the element that should be used as click trigger to select files.
    paramName: "offer[image]"
  });

  myDropzone.on("sending", function(file, xhr, data) {
    var fileName = file.name.replace(/\.[^/.]+$/, "")
    data.append("offer[description]", fileName);
    data.append("offer[show]", $("#show").val()); 

    data.append("offer[start_date(1i)]", $('#start_date__1i').val());
    data.append("offer[start_date(2i)]", $('#start_date__2i').val());
    data.append("offer[start_date(3i)]", $('#start_date__3i').val());
    data.append("offer[start_date(4i)]", $('#start_date__4i').val());
    data.append("offer[start_date(5i)]", $('#start_date__5i').val());

    data.append("offer[expiry_date(1i)]", $('#expiry_date__1i').val());
    data.append("offer[expiry_date(2i)]", $('#expiry_date__2i').val());
    data.append("offer[expiry_date(3i)]", $('#expiry_date__3i').val());
    data.append("offer[expiry_date(4i)]", $('#expiry_date__4i').val());
    data.append("offer[expiry_date(5i)]", $('#expiry_date__5i').val());

    data.append("offer[category_id]", $('#offer_category_id').val());
  });

  myDropzone.on("addedfile", function(file) {
    // Hookup the start button
    file.previewElement.querySelector(".start").onclick = function() { myDropzone.enqueueFile(file); };
  });

  // Update the total progress bar
  myDropzone.on("totaluploadprogress", function(progress) {
    document.querySelector("#total-progress .progress-bar").style.width = progress + "%";
  });

  myDropzone.on("sending", function(file) {
    // Show the total progress bar when upload starts
    document.querySelector("#total-progress").style.opacity = "1";
    // And disable the start button
    file.previewElement.querySelector(".start").setAttribute("disabled", "disabled");
  });

  // Hide the total progress bar when nothing's uploading anymore
  myDropzone.on("queuecomplete", function(progress) {
    document.querySelector("#total-progress").style.opacity = "0";
  });

  myDropzone.on('error', function(file, response) {
      // (assuming your response object has an errorMessage property...)
      console.log(response);
      var errorMessage = "";
      for (var key in response) 
      {
          errorMessage += key + " : " ;
          errorMessage += response[key] + "</br>";
      }
      console.log(errorMessage);
      $('#upload-error').html(errorMessage);
  });

  // Setup the buttons for all transfers
  // The "add files" button doesn't need to be setup because the config
  // `clickable` has already been specified.
  document.querySelector("#actions .start").onclick = function() {
    myDropzone.enqueueFiles(myDropzone.getFilesWithStatus(Dropzone.ADDED));
  };
  document.querySelector("#actions .cancel").onclick = function() {
    myDropzone.removeAllFiles(true);
  };
}