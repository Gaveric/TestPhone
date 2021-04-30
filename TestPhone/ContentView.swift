
import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State var phoneN = ""
    
    @State var opera = ""
    
    var body: some View {
        List { // }(myResponse){myResponse in
            VStack {
                
                HStack {
                    TextField("Name: ", text: $phoneN)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    Button(action: addItem) {
                        Label("Узнать оператора", systemImage: "phone")
                        }
                }
                
                ForEach(items) { item in
                    HStack {
                        
                        Text ("\(item.myOperator ?? "проверка не удалась")")
                        Text("\(item.phone ?? "no phone")")
                        Text("\(item.timestamp!, formatter: itemFormatter)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
        
    }
    
    
    private func addItem() {
        
        guard let url = URL(string: "http://pay.payfon24.ru/mno?phone=\(phoneN)") else { return }
        dump (url)
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            let myResponse = try! JSONDecoder().decode(ResponseModel.self, from: data)
            dump(myResponse)
            opera = myResponse.mnoText
        }
        .resume()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                if opera != "" {
                    let newItem = Item (context: viewContext)
                    newItem.timestamp = Date()
                    newItem.phone = phoneN
                    newItem.myOperator = opera
                    opera = ""
                    
                    do {
                        try viewContext.save()
                    } catch {
                        
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
