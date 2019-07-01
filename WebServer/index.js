$(document).ready(function () {
    $('#sidebarCollapse').on('click', function () {
        $('#sidebar').toggleClass('active');
        $('.overlay').toggleClass('active');
    });

    $('.overlay').on('click', function () {
        $('#sidebar').removeClass('active');
        $('.overlay').removeClass('active');
    });

    console.log("HELLO!");

    var goal = new Goal("Yumyum");
    console.log(goal);
    console.log(goal.getSubAmount());
});

function toggleImportant(s) {
    var importantId = '#' + "important" + s; 
    var flagId = '#' + "flag" + s;
    $(importantId).toggleClass('active');
    $(flagId).toggleClass('active');
    console.log(importantId);
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