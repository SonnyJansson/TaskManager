var projectStructure = {};
var projectName = "";

$(document).ready(function () {
    $('#sidebarCollapse').on('click', function () {
        $('#sidebar').toggleClass('active');
        $('.overlay').toggleClass('active');
        console.log("Yip yip!");
        //document.getElementById("content").style.marginLeft = "250px";
        $('#content').toggleClass('moved');
    });

    $('#noteView').on('click', function () {
        $(".notesMenuCol").addClass('hidden');
    })

    $('.overlay').on('click', function () {
        $('#sidebar').removeClass('active');
        $('.overlay').removeClass('active');
        //document.getElementById("content").style.marginLeft = "0px";
    });

    $('#inputNoteCreate').on('click', function () {
        console.log('Wee!!!');
        noteName = $('#inputNoteName').val();
        noteFormat = $('#inputNoteFormat').val();
        noteTags = $('#inputNoteTags').val();

        if (noteName == '') {
            console.log("Uh-oh");
            return;
        }

        var noteModal = $('#newNoteModal');
        noteModal.modal('hide');

        $('#inputNoteName').val('');
        //$('#inputNoteFormat').val('Markdown');
        $('#inputNoteTags').val('');

        noteJSON = {
            "newNoteName": noteName,
            "newNoteFormat": noteFormat,
            "newNoteTags": noteTags
        }

        console.log(noteJSON);

        $.ajax({
            type: 'POST',
            url: '/newPost',
            data: JSON.stringify(noteJSON),
            success: function(data) { alert('data: ' + data); },
            contentType: "application/json",
            dataType: 'json',
        });
    });

    projectName = "Test Project";

    requestProjectStructure();

    console.log("HELLO!");

    var goal = new Goal("Yumyum");
    console.log(goal);
    console.log(goal.getSubAmount());

    checkBoxes();
});

function logStructure() {
    console.log(projectStructure);
}

function requestProjectStructure() {
    /*fetch("/p/" + projectName + "/structure.json").then(function(response) {
        return response.json();
    });*/

    $.getJSON("/p/" + projectName + "/structure.json", function(data) {
        console.log(data);
        projectStructure = JSON.parse(JSON.stringify(data));
    });
}

function toggleImportant(s) {
    var importantId = '#' + "important" + s; 
    var flagId = '#' + "flag" + s;
    $(importantId).toggleClass('active');
    $(flagId).toggleClass('active');
    console.log(importantId);
    console.log(stringToId(s));

    goal = findGoal(stringToId(s));
    important = goal.goalImportant;

    console.log(important);

    if(important) {
        console.log("WEEE");
        goal.goalImportant = false;
    }
    else {
        goal.goalImportant = true;
    }

    pushChanges();
}

function toggleExpand(s) {
    var subListId = '#' + "subList" + s;
    var expandId = '#' + "expand" + s;
    var separatorId = '#' + "subGoalSeparator" + s;
    $(subListId).toggleClass('active');
    $(expandId).toggleClass('fa-chevron-down');
    $(expandId).toggleClass('fa-chevron-left');
    $(separatorId).toggleClass('active');
    console.log(subListId); // Toggle the down arrow class and the side arrow class so that they alternate
    // Also label the separating line between a goal and its subgoals so that it can have its active tag toggled

    /*
    goal = findGoal(stringToId(s));
    collapsed = goal.goalCollapsed;

    if(collapsed) {
        goal.goalCollapsed = false;
    }
    else {
        goal.goalCollasped = true;
    }

    pushChanges();
    */
}

function addCheck(s) {
    id = stringToId(s);
    goal = findGoal(stringToId(s));

    var parentId = id;
    parentId.pop();

    var counterId = "";
    checkId = "#goalCheck" + s;

    if(parentId.length == 0) {
        counterId = "#goalCounterOverall";
    }
    else {
        counterId = "#goalCount" + idToString(parentId);
    }

    console.log("Should check: " + checkId);

    if(goal.goalFinished) {
        return;
    }

    console.log("Checking: " + checkId);

    // Add finished
    goal.goalFinished = true;
    progress = $(counterId).text().split('/');
    newCount = parseInt(progress[0]) + 1;
    $(counterId).text([newCount, "/", progress[1]].join(''));
    $(checkId).addClass("checked");
    
    checkChildren(goal);
    checkBoxes();

    // Push changes
    pushChanges();
}

function removeCheck(s) {
    id = stringToId(s);
    goal = findGoal(stringToId(s));

    var parentId = id;
    parentId.pop();

    var counterId = "";
    checkId = "#goalCheck" + s;

    if(parentId.length == 0) {
        counterId = "#goalCounterOverall";
    }
    else {
        counterId = "#goalCount" + idToString(parentId);
    }

    if(!goal.goalFinished) {
        return;
    }

    // Remove finished
    goal.goalFinished = false;
    progress = $(counterId).text().split('/');
    newCount = parseInt(progress[0]) - 1;
    $(counterId).text([newCount, "/", progress[1]].join(''));
    $(checkId).removeClass("checked");

    unCheckChildren(goal);
    checkBoxes();

    // Push changes
    pushChanges();
}


function toggleCheck (s) {
    id = stringToId(s);
    goal = findGoal(stringToId(s));

    finished = goal.goalFinished;
    if (finished) {
        removeCheck(s);
    }
    else {
        addCheck(s);
    }

    // Push changes
    pushChanges();
}

function checkChildren(goal) {
    for(g of goal.subGoals) {
        addCheck(idToString(g.goalID));
        console.log("checkId: " + checkId);

        $(checkId).addClass("checked");

        checkChildren(g);
    }
}

function unCheckChildren(goal) {
    for(g of goal.subGoals) {
        removeCheck(idToString(g.goalID));
        console.log("checkId: " + checkId);

        $(checkId).removeClass("checked");

        unCheckChildren(g);
    }
}

function findGoal(id) {
    if (id.length == 0) {
        throw ("Unvalid goalID: " + id);
    }

    structureLoc = projectStructure.goals;

    for (i of id) {
        for (goal of structureLoc) {
            if (JSON.stringify(goal.goalID) == JSON.stringify(id)) {
                return goal;
            }
            else if (goal.goalID.last() == i) {
                structureLoc = goal.subGoals;
                break;
            }
        }
    }

    // Keep track of parent so that it can keep track of checked children
}


function findChecked() {
    var checkboxes = document.getElementsByClassName('goalCheckbox');

    for (box of checkboxes) {
        if(box.checked) {
        }
    }
}

function checkBoxes() {
    var checkboxes = document.getElementsByClassName('goalCheckbox');

    for (box of checkboxes) {
        if($(box).hasClass("checked")) {
            box.checked = true;
        }
        else {
            box.checked = false;
        }
    }

}

function pushChanges () {
    // $.post("/projectStructure", JSON.stringify(projectStructure), function(data, status) {
    //     console.log(`${data} and status us ${status}`);
    // }, 'json');

    $.ajax({
        type: 'POST',
        url: '/projectStructure',
        data: JSON.stringify(projectStructure),
        success: function(data) { alert('data: ' + data); },
        contentType: "application/json",
        dataType: 'json',
    });
}

if (!Array.prototype.last) {
    Array.prototype.last = function() {
        return this[this.length - 1];
    };
}

function stringToId (s) {
    id = [];

    for (character of s) {
        if(!isNaN(character)) {
            id.push(parseInt(character));
        }
    }

    return id;
}

function idToString(id) {
    outputString = "";

    for (var i=0; i < id.length; i++) {
        outputString += id[i];

        if(i != id.length - 1) {
            outputString += '_';
        }
    }

    return outputString;
}

function renderProjectStructure() {
    document.getElementById('project').innerHTML = "Project HTML";
}


function openDocument(uuid, name) {
    $.get("/note/" + uuid, function(data) {
        console.log(data);
        document.getElementById("noteView").innerHTML = data;
    });

    $(".notesMenuCol").addClass("hidden");
    document.getElementById("noteNavName").innerHTML = name;
}

function openNotesMenu() {
    $(".notesMenuCol").removeClass("hidden");
}

// Possibly add a function that allows you to set all the toggles in sync

// Maybe store the expand state for all the goals so that big projects are not cluttered every time you open them and so you can keep focusing on the goal that is expanded

class Goal {
    constructor(value) {
        this.value = value;
        this.children = new Array();
    }

    getSubAmount() {
        return this.children.length; 
    }

    insertSub(subGoal) {
        this.children.push(subGoal);
    } 

    toHTML() {
    }
}
