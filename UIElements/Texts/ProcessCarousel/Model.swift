import Foundation

class Task: NSObject {

    enum State {
        case planned
        case running
        case suspended
        case completed
        case canceled
    }
    
    var title: String = ""
    var order: Int = 0
    var state: State = .suspended
    var canBeMoved: Bool = true
    var canBeDeleted: Bool = true
    
    init (title: String, order: Int, state: State, canBeMoved: Bool, canBeDeleted: Bool) {
        
        self.title = title
        self.order = order
        self.state = state
        self.canBeMoved = canBeMoved
        self.canBeDeleted = canBeDeleted
    }
}


class Goal {
    
    enum State {
        case planned
        case running
        case suspended
        case completed
        case canceled
    }
    
    var title: String? = nil
    var state: State = .running
    var tasks: [Task]? = nil

    
    init (title: String?, state: State, tasks: [Task]) {
        
        self.title = title
        self.state = state
        self.tasks = returnOrdered(tasks: tasks)
    }
    
    
    func returnOrdered (tasks: [Task]) -> [Task] {
        let sortedTasks = tasks.sorted {
            $0.order < $1.order
        }
        
        return sortedTasks
    }

    
}

class Process {
    
    var taskSet1: [Task]
    var taskSet2: [Task]
    var taskSet3: [Task]
    var taskSet4: [Task]
    
    var goals: [Goal]
    var currentGoal: Goal?
    let currentGoalIndex: Int = 0
    
    init() {

        taskSet1 = [
            
            Task(title: "Отремонтировать неремонтопригодный мотороллер", order: 0, state: .completed, canBeMoved: true, canBeDeleted: false),
            Task(title: "Задекларировать доходы, полученные от перепродажи сахарного тростника", order: 1, state: .running, canBeMoved: true, canBeDeleted: true),
            Task(title: "Выбрать шляпу", order: 5, state: .running, canBeMoved: false, canBeDeleted: true),
            Task(title: "Подать документы на регистрацию юрлица", order: 2, state: .running, canBeMoved: true, canBeDeleted: true),
            Task(title: "Любой длинный текст, который нормальные люди в заголовок не напишут", order: 3, state: .running, canBeMoved: true, canBeDeleted: true),
            Task(title: "i", order: 4, state: .running, canBeMoved: true, canBeDeleted: true),
        ]

        
        taskSet2 = [
            
            Task(title: "Check the car", order: 0, state: .completed, canBeMoved: true, canBeDeleted: false),
            Task(title: "Disassemble the car", order: 1, state: .running, canBeMoved: true, canBeDeleted: true),
            Task(title: "Sell", order: 5, state: .running, canBeMoved: false, canBeDeleted: true),
            Task(title: "Fix repairable parts", order: 2, state: .running, canBeMoved: true, canBeDeleted: true),
            Task(title: "Change unrepairable parts", order: 3, state: .running, canBeMoved: true, canBeDeleted: true),
            Task(title: "Assemble the car", order: 4, state: .running, canBeMoved: true, canBeDeleted: true),
        ]

        taskSet3 = []
        
        taskSet4 = [
            
            Task(title: "Check", order: 0, state: .running, canBeMoved: true, canBeDeleted: false),
            Task(title: "Disassemble", order: 1, state: .running, canBeMoved: true, canBeDeleted: true),
            Task(title: "Sell", order: 5, state: .running, canBeMoved: false, canBeDeleted: true),
            Task(title: "Fix", order: 2, state: .running, canBeMoved: true, canBeDeleted: true),
            Task(title: "Change", order: 3, state: .running, canBeMoved: true, canBeDeleted: true),
            Task(title: "Assemble", order: 4, state: .running, canBeMoved: true, canBeDeleted: true),
        ]

        
        goals = [
            
            Goal(title: "Неприлично длинная по своей формулировке цель", state: .running, tasks: taskSet1), //Get rid of the car
            Goal(title: "Aerocomic goal", state: .completed, tasks: taskSet2),
            Goal(title: "Aerocomic goal", state: .completed, tasks: taskSet3),
            Goal(title: nil, state: .completed, tasks: taskSet2)
        ]
        
        currentGoal = goals[currentGoalIndex]
    }
    
    
    func moveItem(at fromIndex: Int, to toIndex: Int) {
        
        let task = currentGoal?.tasks?.remove(at: fromIndex)
        currentGoal?.tasks?.insert(task!, at: toIndex)
        
        reorder()
    }
    
    
    func reorder() {
        
        
        for (index, task) in (currentGoal?.tasks?.enumerated())! {
            
            task.order = index
            
        }
        
    }
}

