#MST-Prim

-Descrizione: 
Risolvere il problema MST, su grafi non diretti e connessi con pesi 
non negativi, implementando l'algoritmo di Prim. 
L'implementazione del programma è principalmente basato sull'utilizzo di hash-tables
le quali, immagazzinando i dati, costituiranno la base di conoscenza; le hash-tables sono le seguenti:

Grafi:
*graphs*
*vertices*
*arcs*

MinHeap:
*heaps*
*positions*

PRIM:
*vertex-keys*
*previous*
*visited*
 

-LIBRERIA PREDICATI:


-legenda:
### prima di un nome di funzione indica che si tratta di una funzione non
descritta nelle API ma implementata da noi. 


INTERFACCIA PER LA MANIPOLAZIONE DEI GRAFI:


is-graph 
graph-id --> graph-id o NIL
descrizione:
se il grafo esiste ritorna il graph-id altrimenti NIL se non è stato creato.


new-graph 
graph-id --> graph-id
descrizione:
Inserisce un nuovo grafo nella hash-table *graphs* con seguente rappresentazione:
(graph-id).

delete-graph
graph-id --> NIL
descrizione:
Rimuove tutte le parti del grafo "graph-id" nelle rispettive hash-table
*graphs*, *vertices*, *arcs*.


new-vertex
graph-id vertex-id --> vertex-rep
descrizione:
Aggiunge il vertice "vertex-id" nella hash-table *vertices*, per il rispettivo
"graph-id".
la vertex-rep ha la seguente rappresentazione: (list 'vertex graph-id vertex-id).


graph-vertices
graph-id --> vertex-rep-list
descrizione:
Ritorna una lista di vertici del grafo "graph-id".


new-arc
graph-id vertex-id1 vertex-id2 &optional weight --> arc-rep
descrizione:
Aggiunge una coppia di archi nella hash-table arcs, se l'arco e' gia
presente ma con peso diverso aggiorna il peso dell'arco.
la rappresentazione delle arc-rep nella hash-table e' la seguente:
(list 'arc graph-id vertex-id1 vertex-id2 weight)
(list 'arc graph-id vertex-id2 vertex-id1 weight)


graph-arcs
graph-id --> arc-rep-lisp
descrizione:
Ritorna una lista di archi del grafo "graph-id", la lista e' composta da
entrambi le coppie di archi.


graph-vertex-neighbors
graph-id vertex-id --> arc-rep-list
descrizione:
Ritorna una lista arc-rep-list contenente gli archi del tipo
(list 'arc graph-id vertex-id N W)
dove N sono i vertici immediatamente raggiungibili da vertex-id.


graph-vertex-adjacent
graph-id vertex-id --> vertex-rep-list
descrizione:
Ritorna una lista vertex-rep-list contenente i vertici adiacenti a vertex-id
(list 'vertex graph-id N).


graph-print
graph-id
descrizione:
Stampa in output la lista dei vertici e degli archi relativi al graph-id.


------------------------------------------------------------------------


INTERFACCIA PER LA CREAZIONE E MANIPOLAZIONE DEI MINHEAP:


new-heap
H &optional (capacity 42) --> heap-rep
descrizione:
Inserisce un nuovo heap nella hash-table *heaps*, il valore associato alla chiave
è il seguente:
(list 'heap heap-id heap-size actual-heap), con dimensione dello heap-size settato
a 0 ed array di dimensione capacity al momento della creazione.
per accedere ad ogni campo della heap-rep sono definite le seguenti funzioni:


## is-heap
heap-id --> heap-rep or NIL
descrizione:
Ritorna l'heap-rep se esiste altrimenti NIL.


-heap-id
heap-rep --> heap-id
descrizione: 
Ritorna l'heap-id dello heap.

-heap-size
heap-rep --> heap-size
descrizione: Ritorna la dimensione dello heap.
 

-heap-actual-heap
heap-rep --> actual-heap
descrizione: 
Ritorna il contenuto dello heap, ovvero l'array associato ad esso.


heap-delete
heap-id --> T
descrizione: 
Rimuove l'intero heap associato ad "heap-id".

heap-empty
heap-id --> boolean
descrizione: 
Ritorna T se l'heap heap-id non contiene elementi.


heap-not-empty
heap-id --> boolean
descrizione: 
Ritorna T se l'heap heap-id contiene almeno un elemento.


heap-head
heap-id --> (K V)
descrizione: 
Ritorna una lista di 2 elementi con K chiave minima e V il suo valore associato.


heap-insert
heap-id K V --> boolean
descrizione: 
Inserisce l'elemento V, con chiave K, all'interno dello heap.
La funzione si preoccupa anche di aggiornare la dimensione dell'array associato allo
heap, ogni volta che si raggiunge la capacità massima dello heap la dimensione dell'array viene aumentata di 
1/2 della capacità attuale.
Ad ogni inserimento la proprietà dello heap viene mantenuta.


### heap-property-check
heap-id pos --> boolean
descrizione:
Ritorna T se la proprietà di MinHeap viene mantenuta controllando la K di pos e pos/2.


heap-extract
heap-id --> (K V)
descrizione:
Ritorna la lista con (K V) dove K è la chiave minima dello heap rimuovendola da 
quest'ultimo, lo stato dello heap viene aggiornato affinche la proprietà di MinHeap
sia mantenuta.
Come per heap-insert, la capacità dell'array associato allo heap diminuisce se la dimensione
dello heap è la metà o meno della dimensione dell'array.


### heapify
heap-id p --> boolean
descrizione:
La funzione è vera quando la chiave K dell'elemento in posizione P è minore
della chiave di entrambi i figli in posizione p*2 e (p*2 + 1).


### find-sons 
heap-id --> p
descrizione:
Ritorna una lista di (K V) dei figli dell'elemento in posizione p.
La lunghezza di questa lista varia a seconda del numero di figli dell'elemento
in posizione p.


heap-modify-key
heap-id new-key old-key V --> boolean
descrizione:
Sostituisce la chiave  dell'elemento (old-key V) con new-key.
per mantenere la proprietà di minHeap abbiamo aggiunto un hash-table *positions*
che tiene traccia della posizione di ogni elemento presente nello heap
chiave: (heap-id (K V)) valore: posizione.
Quest'ultimi saranno aggiornati in concomitanza dell'aggiornamento dello heap.


heap-print
heap-id --> boolean
descrizione:
Stampa sulla console lo stato dell'heap.


------------------------------------------------------------------------ 


INTERFACCIA PER L'APPLICAZIONE DELL'ALGORITMO DI PRIM


mst-vertex-key
graph-id vertex-id --> k
descrizione:
Ritorna il peso minimo di un arco (appartenente a graph-id) che connette vertex-id nell'albero minimo,
se l'arco non esiste k corrisponde a MOST-POSITIVE-DOUBLE-FLOAT.
Il valore k si aggiorna durante l'esecuzione dell' algoritmo di PRIM.


mst-previous
graph-id V --> U
descrizione:
Ritorna il vertice U, genitore di V del MST.
Il valore di U si aggiorna durante l'esecuzione dell'algoritmo di PRIM.


mst-prim
graph-id source --> NIL
descrizione:
Dopo l'esecuzione i valori di ogni vertice presente in *vertex-keys* e *previous*
sono aggiornati rispettando la soluzione del problema di MST.
Per ottenere quest'ultimo la funzione sfrutta le seguenti funzioni di appoggio:


### build-heap
graph-id source --> NIL
descrizione:
Termina con un effetto collaterale; inizializza i valori di *previous* e *vertex-keys*
per ogni vertice appartenente al grafo graph-id.


### decrease-queue 
heap-id --> NIL
descrizione:
Estrae la testa dello heap e chiama la funzione check-adjs, per ogni elemento dell'heap
fino a quando non contiene alcun elemento.


### check-adjs 
heap-id lista --> NIL
descrizione:
Aggiorna, per ogni vertice appartenente alla lista, i valori di *previous* e *vertex-keys*
modificando lo stato dell'heap, questo e' influenzato dalla presenza del vertice nella hash-table *visited*.


mst-get
graph-id source --> preorder-mst
Ritorna la lista degli archi del MST ordinata secondo attraversamento preorder fatta rispetto al
peso dell'arco.
Durante la sua esecuzione, la funzione rimuove tutte le occorrenze di ogni vertice presenti in *previous*,
*vertex-keys* e *visited*.
A parità di peso segue l'ordinamento lessicografico del vertice;
per permettere questo utilizziamo le seguenti funzioni di appoggio:


### list-insert
graph-id father l --> preorder-mst
descrizione:
Costruisce ricorsivamente la lista degli archi appartenenti al MST.


### lista-figli-previous
graph-id source --> lista-figli-ordinata
descrizione:
Ritorna un lista di K associati a V figli di source (secondo la hash-table *previous*).
Per ordinarli secondo il peso e l'ordinamento lessicografico si implementa una funzione
usata dalla sort che confronta coppie di elementi.


### transform-list
l-double --> l-single
descrizione:
Data in input una lista di coppie (V K) ritorna la corrispondente lista di soli K.


### sort-doppio
term1 term2 --> boolean 
descrizione:
Confronta i K (pesi) di term1 e term2 se non sono uguali ritornando true se k di term1
e minore del k di term2 altrimenti false;
se i pesi sono uguali il confronto viene applicato ai V dei 2 termini dalla seguenti funzione:


### vertex<
term1 term2 --> boolean
descrizione:
Per tutte le possibili coppie di termini ((numero numero), (simbolo simbolo), misto)
viene applicata la rispettiva funzione di confronto.


### number<
term1 term2 --> boolean
descrizione:
Confronta i pesi di term1 e term2 restituendo il risultato del confronto.
