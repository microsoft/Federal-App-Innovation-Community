    <script>
        var maxBlockSize = 512 * 1024;//Each file will be split in 256 KB.
        var numberOfBlocks = 1;
        var selectedFile = null;
        var currentFilePointer = 0;
        var totalBytesRemaining = 0;
        var blockIds = new Array();
        var blockIdPrefix = "block-";
        var submitUri = null;
        var bytesUploaded = 0;
         
        $(document).ready(function () {
            $("#output").hide();
            $("#file").bind('change', handleFileSelect);
            if (window.File && window.FileReader && window.FileList && window.Blob) {
                // Great success! All the File APIs are supported.
            } else {
                alert('The File APIs are not fully supported in this browser.');
            }
        });
         
        //Read the file and find out how many blocks we would need to split it.
        function handleFileSelect(e) {
            maxBlockSize = 512 * 1024;
            currentFilePointer = 0;
            totalBytesRemaining = 0;
            var files = e.target.files;
            selectedFile = files[0];
            $("#output").show();
            $("#fileName").text(selectedFile.name);
            $("#fileSize").text(selectedFile.size);
            $("#fileType").text(selectedFile.type);
            var fileSize = selectedFile.size;
            if (fileSize < maxBlockSize) {
                maxBlockSize = fileSize;
                console.log("max block size = " + maxBlockSize);
            }
            totalBytesRemaining = fileSize;
            if (fileSize % maxBlockSize == 0) {
                numberOfBlocks = fileSize / maxBlockSize;
            } else {
                numberOfBlocks = parseInt(fileSize / maxBlockSize, 10) + 1;
            }
            console.log("total blocks = " + numberOfBlocks);
            var baseUrl = $("#sasUrl").val();
            var indexOfQueryStart = baseUrl.indexOf("?");
            submitUri = baseUrl.substring(0, indexOfQueryStart) + '/' + selectedFile.name + baseUrl.substring(indexOfQueryStart);
            console.log(submitUri);
        }
 
        var reader = new FileReader();
 
        reader.onloadend = function (evt) {
            if (evt.target.readyState == FileReader.DONE) { // DONE == 2
                var uri = submitUri + '&comp=block&blockid=' + blockIds[blockIds.length - 1];
                var requestData = new Uint8Array(evt.target.result);
                $.ajax({
                    url: uri,
                    type: "PUT",
                    data: requestData,
                    processData: false,
                    beforeSend: function(xhr) {
                        //xhr.setRequestHeader('x-ms-blob-type', 'BlockBlob');
                        //xhr.setRequestHeader('Content-Length', requestData.length);
                    },
                    success: function (data, status) {
                        console.log(data);
                        console.log(status);
                        bytesUploaded += requestData.length;
                        var percentComplete = ((parseFloat(bytesUploaded) / parseFloat(selectedFile.size)) * 100).toFixed(2);
                        $("#fileUploadProgress").text(percentComplete + " %");
                        uploadFileInBlocks();
                    },
                    error: function(xhr, desc, err) {
                        console.log(desc);
                        console.log(err);
                    }
                });
            }
        };
 
        function uploadFileInBlocks() {
            if (totalBytesRemaining > 0) {
                console.log("current file pointer = " + currentFilePointer + " bytes read = " + maxBlockSize);
                var fileContent = selectedFile.slice(currentFilePointer, currentFilePointer + maxBlockSize);
                var blockId = blockIdPrefix + pad(blockIds.length, 6);
                console.log("block id = " + blockId);
                blockIds.push(btoa(blockId));
                reader.readAsArrayBuffer(fileContent);
                currentFilePointer += maxBlockSize;
                totalBytesRemaining -= maxBlockSize;
                if (totalBytesRemaining < maxBlockSize) {
                    maxBlockSize = totalBytesRemaining;
                }
            } else {
                commitBlockList();
            }
        }
         
        function commitBlockList() {
            var uri = submitUri + '&comp=blocklist';
            console.log(uri);
            var requestBody = '<?xml version="1.0" encoding="utf-8"?><BlockList>';
            for (var i = 0; i < blockIds.length; i++) {
                requestBody += '<Latest>' + blockIds[i] + '</Latest>';
            }
            requestBody += '</BlockList>';
            console.log(requestBody);
            $.ajax({
                url: uri,
                type: "PUT",
                data: requestBody,
                beforeSend: function (xhr) {
                    //xhr.setRequestHeader('x-ms-blob-content-type', selectedFile.type);
                    //xhr.setRequestHeader('Content-Length', requestBody.length);
                },
                success: function (data, status) {
                    console.log(data);
                    console.log(status);
                },
                error: function (xhr, desc, err) {
                    console.log(desc);
                    console.log(err);
                }
            });
 
        }
        function pad(number, length) {
            var str = '' + number;
            while (str.length < length) {
                str = '0' + str;
            }
            return str;
        }
    </script>